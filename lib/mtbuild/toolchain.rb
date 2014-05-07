module MTBuild

	class Toolchain

    attr_accessor :output_folder
    attr_accessor :project_folder
    attr_accessor :binary_decorator

		def initialize(configuration)
      @output_folder = ''
      @project_folder = ''
      @binary_decorator = ''
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
      include_objects = Utils.ensure_array(include_objects).to_a.flatten
      @include_objects |= include_objects
    end

    def add_include_paths(include_paths)
      include_paths = Utils.ensure_array(include_paths).to_a.flatten
      @include_paths |= include_paths
    end

    def add_library_paths(library_paths)
      library_paths = Utils.ensure_array(library_paths).to_a.flatten
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
      return Utils.ensure_array(paths).to_a.flatten.collect{ |p| (File.join('$(PROJECT_DIR)', p))}
    end

    @registered_toolchains = {}

    def self.register_toolchain(toolchain_name, toolchain_class)
      @registered_toolchains[toolchain_name] = toolchain_class;
    end

    def self.create_toolchain(toolchain_configuration)
      toolchain_name = toolchain_configuration.fetch(:name, nil)
      fail "error: toolchain name not specified." if toolchain_name.nil?

      toolchain_class = @registered_toolchains.fetch(toolchain_name, nil)
      if !toolchain_class
        toolchain_file = File.join('mtbuild', 'toolchains', toolchain_name.to_s)
        begin
          require toolchain_file
        rescue LoadError
          fail "error: could not load #{toolchain_file}."
        end
      end
      toolchain_class = @registered_toolchains.fetch(toolchain_name, nil)
      fail "error: toolchain #{toolchain_name} could not be found." if toolchain_class.nil?
      return Object::const_get(toolchain_class).new(toolchain_configuration)
    end

    include Rake::DSL
	end

end
