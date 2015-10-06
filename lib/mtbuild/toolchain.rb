module MTBuild

  # This is the base class for all toolchain types.
  class Toolchain

    # The toolchain's output folder
    attr_accessor :output_folder

    # The project's folder. Relative path references are interpreted as
    # relative to this folder.
    attr_accessor :project_folder

    # Text to append to the name of output files
    attr_accessor :output_decorator

    # parent configuration
    attr_accessor :parent_configuration

    def initialize(parent_configuration, toolchain_configuration)
      @output_folder = ''
      @project_folder = ''
      @output_decorator = ''
      @include_objects = []
      @include_paths = []
      @library_paths = []
      @parent_configuration = parent_configuration

      add_include_paths(expand_project_relative_paths(toolchain_configuration.fetch(:include_paths, [])))
      add_include_objects(expand_project_relative_paths(toolchain_configuration.fetch(:include_objects, [])))
      add_library_paths(expand_project_relative_paths(toolchain_configuration.fetch(:library_paths, [])))
    end

    # Retrieve a list of additional objects to link with
    def get_include_objects
      @include_objects.collect {|i| File.expand_path(i.gsub('$(PROJECT_DIR)', @project_folder))}
    end

    # Retrieve a list of include paths to compile with
    def get_include_paths
      @include_paths.collect {|i| File.expand_path(i.gsub('$(PROJECT_DIR)', @project_folder))}
    end

    # Retrieve a list of library paths to link with
    def get_library_paths
      @library_paths.collect {|i| File.expand_path(i.gsub('$(PROJECT_DIR)', @project_folder))}
    end

    # Add an additional object to the list of additional objects to link with
    def add_include_objects(include_objects)
      include_objects = Utils.ensure_array(include_objects).to_a.flatten
      @include_objects |= include_objects
    end

    # Add an include path to the list of include paths to compile with
    def add_include_paths(include_paths)
      include_paths = Utils.ensure_array(include_paths).to_a.flatten
      @include_paths |= include_paths
    end

    # Add a library path to the list of library paths to link with
    def add_library_paths(library_paths)
      library_paths = Utils.ensure_array(library_paths).to_a.flatten
      @library_paths |= library_paths
    end

    # Scan source files for any special processing needs
    def scan_sources(source_files)
    end

    # Create Rake tasks for compilation
    def create_compile_tasks(source_files)
      fail "Toolchain didn't provide create_compile_tasks"
    end

    # Create Rake tasks for archival
    def create_static_library_tasks(objects, library_name)
      fail "Toolchain didn't provide create_static_library_tasks"
    end

    # Create Rake tasks for linking
    def create_application_tasks(objects, executable_name)
      fail "Toolchain didn't provide create_executable_tasks"
    end

    private

    def expand_project_relative_paths(paths)
      return Utils.ensure_array(paths).to_a.flatten.collect{ |p| ((Pathname.new p).relative?) ? (File.join('$(PROJECT_DIR)', p)) : p}
    end

    @registered_toolchains = {}

    def self.register_toolchain(toolchain_name, toolchain_class)
      @registered_toolchains[toolchain_name] = toolchain_class;
    end

    def self.create_toolchain(parent_configuration, toolchain_configuration)
      toolchain_name = toolchain_configuration.fetch(:name, nil)
      fail "error: toolchain name not specified." if toolchain_name.nil?

      toolchain_class = @registered_toolchains.fetch(toolchain_name, nil)
      if !toolchain_class
        toolchain_file = File.join('mtbuild', 'toolchains', toolchain_name.to_s)
        begin
          require toolchain_file
        rescue LoadError
        end
      end
      toolchain_class = @registered_toolchains.fetch(toolchain_name, nil)
      fail "error: toolchain #{toolchain_name} could not be found." if toolchain_class.nil?
      return Object::const_get(toolchain_class).new(parent_configuration, toolchain_configuration)
    end

    include Rake::DSL
  end

end
