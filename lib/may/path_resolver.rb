module May
  class ProjectResolver
    def initialize(root_dir)
      @root_dir = root_dir
    end

    def source_project(project_name = File.basename(@root_dir))
      join(project_name)
    end

    def test_project(project_name = File.basename(@root_dir))
      join(project_name + 'Tests')
    end

    private
    def join(project_name)
      File.join(@root_dir, project_name)
    end
  end

  class FileResolver
    def initialize(base_dir)
      @base_dir = base_dir
    end

    def header_file(path)
      join(path + '.h')
    end

    def implementation_file(path)
      join(path + '.m')
    end

    def test_file(path)
      join(path + 'Test.m')
    end
  end

  class TemplateResolver < FileResolver
    EXTENTION_NAME = '.erb'
    private
    def join(path)
      template_filename = path + EXTENTION_NAME
      File.join(@base_dir, template_filename)
    end
  end

  class DestinationResolver < FileResolver
    private
    def join(filename)
      File.join(@base_dir, filename)
    end
  end

  class PathResolver
    def initialize(context)
      @context = context
    end

    def each(path, template_name)
      raise unless block_given?
      yield template_resolver.header_file(template_name), source_project.header_file(path)
      yield template_resolver.implementation_file(template_name), source_project.implementation_file(path)
      yield template_resolver.test_file(template_name), test_project.test_file(path)
    end

    def template_resolver
      @template_resolver ||= TemplateResolver.new(@context.template_dir)
    end

    def project_resolver
      @project_resolver ||= ProjectResolver.new(@context.root_dir)
    end

    def source_project
      @source_project ||= DestinationResolver.new(project_resolver.source_project)
    end

    def test_project
      @test_project ||= DestinationResolver.new(project_resolver.test_project)
    end
  end
end
