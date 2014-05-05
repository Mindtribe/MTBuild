module MTBuild

	class Toolchain

    attr_accessor :output_folder
    attr_accessor :project_folder

		def initialize(configuration)
      @output_folder = ''
      @project_folder = ''
      @include_objects = []
      @include_paths = []
      @library_paths = []

      add_include_paths(expand_project_relative_paths(configuration.fetch(:include_paths, [])))
      add_include_objects(expand_project_relative_paths(configuration.fetch(:include_objects, [])))
      add_library_paths(expand_project_relative_paths(configuration.fetch(:library_paths, [])))
		end

    def get_include_objects
      @include_objects.collect {|i| File.expand_path(i.gsub('$(PROJECT_DIR)', @project_folder))}
    end

    def get_include_paths
      @include_paths.collect {|i| File.expand_path(i.gsub('$(PROJECT_DIR)', @project_folder))}
    end

    def get_library_paths
      @library_paths.collect {|i| File.expand_path(i.gsub('$(PROJECT_DIR)', @project_folder))}
    end

    def add_include_objects(include_objects)
      include_objects = [include_objects] if include_objects.is_a?(String)
      include_objects = include_objects.to_a.flatten
      @include_objects |= include_objects
    end

    def add_include_paths(include_paths)
      include_paths = [include_paths] if include_paths.is_a?(String)
      include_paths = include_paths.to_a.flatten
      @include_paths |= include_paths
    end

    def add_library_paths(library_paths)
      library_paths = [library_paths] if library_paths.is_a?(String)
      library_paths = library_paths.to_a.flatten
      @library_paths |= library_paths
    end

    def create_compile_tasks(source_files)
      fail "Toolchain didn't provide create_compile_tasks"
    end

    def create_static_library_tasks(objects, library_name)
      fail "Toolchain didn't provide create_static_library_tasks"
    end

    def create_application_tasks(objects, executable_name)
      fail "Toolchain didn't provide create_executable_tasks"
    end

    private

    def expand_project_relative_paths(paths)
      paths = [paths] if paths.is_a?(String)
      paths = paths.to_a.flatten
      return paths.collect { |p| (File.join('$(PROJECT_DIR)', p))}
    end

    include Rake::DSL
	end

end
