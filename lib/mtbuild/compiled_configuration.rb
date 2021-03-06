module MTBuild
  require 'mtbuild/configuration'
  require 'mtbuild/toolchain'

  # This is the base class for configurations representing compiled objects
  # (libraries, applications, etc.)
  class CompiledConfiguration < Configuration

    # A list of Rake tasks that this configuration depends upon
    attr_reader :dependencies

    # A list of source files that will be compiled
    attr_reader :source_files

    # A list of Rake test tasks that will execute after this configuration builds
    attr_reader :tests

    def initialize(parent_project, output_folder, configuration_name, configuration)
      super
      @dependencies = expand_configuration_wildcards(namespace_tasks(configuration.fetch(:dependencies, [])))
      @dependencies |= configuration.fetch(:rake_dependencies, [])
      @default_toolchain_config = configuration[:toolchain]
      @default_toolchain = Toolchain.create_toolchain(self, @default_toolchain_config)

      @source_files = Utils.expand_file_list(configuration.fetch(:sources, []), configuration.fetch(:excluded_sources, []), @project_folder)
      @toolchains = {@default_toolchain => @source_files}

      @tests = namespace_tasks(Utils.ensure_array(configuration.fetch(:tests, [])))
    end

    # This method adds source files with their own toolchains. Use this method
    # to add any source files that need special toolchain settings.
    def add_sources(sources, excludes=[], toolchain_configuration)
      merged_configuration = Utils.merge_configurations(@default_toolchain_config, toolchain_configuration)
      toolchain = Toolchain.create_toolchain(self, merged_configuration)
      @toolchains[toolchain] = Utils.expand_file_list(sources, excludes, @project_folder)
    end

    # Create the actual Rake tasks that will perform the configuration's work
    def configure_tasks
      super
      all_sources = []
      @toolchains.each do |toolchain, sources|
        all_sources |= sources
        toolchain.output_folder = @output_folder
        toolchain.project_folder = @project_folder
        toolchain.output_decorator = "-#{@configuration_name}"
        CompiledConfiguration.add_framework_dependencies_to_toolchain(toolchain, @dependencies)
      end
      # Give the default toolchain an opportunity to scan all source files for
      # any special needs. For example, a toolchain might look for .cpp files
      # to determine that it should link a project with the "g++" vs "gcc".
      @default_toolchain.scan_sources(all_sources)
    end

    private

    def check_configuration(configuration)
      super
      fail "No toolchain specified for #{@parent_project.project_name}:#{@configuration_name}" if configuration.fetch(:toolchain, nil).nil?
    end

    def self.add_framework_dependencies_to_toolchain(toolchain, *dependencies)
      dependencies.each do |dependency|
        if dependency.respond_to? :to_ary
          CompiledConfiguration.add_framework_dependencies_to_toolchain(toolchain, *dependency.to_ary)
        else
          task_dependency = Rake.application.lookup(dependency)
          fail "Unable to locate task for dependency: #{dependency}" if task_dependency.nil?
          toolchain.add_include_paths(task_dependency.api_headers) if task_dependency.respond_to? :api_headers
          toolchain.add_include_paths(task_dependency.configuration_headers) if task_dependency.respond_to? :configuration_headers
          toolchain.add_include_objects(task_dependency.library_files) if task_dependency.respond_to? :library_files
        end
      end
    end

    include Rake::DSL
  end

end
