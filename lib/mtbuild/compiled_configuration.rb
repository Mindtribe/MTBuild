module MTBuild
  require 'mtbuild/configuration'

	class CompiledConfiguration < Configuration

    attr_reader :dependencies
    attr_reader :include_paths
    attr_reader :output_folder
    attr_reader :project_folder
    attr_reader :source_files
    attr_reader :toolchain
    attr_reader :tests

		def initialize(project_name, project_folder, configuration_name, configuration)
      super
      check_configuration(configuration)

      @dependencies = configuration.fetch(:dependencies, [])
      @output_folder = File.expand_path(File.join(MTBuild.build_folder, @project_name.to_s, @configuration_name.to_s))
      @default_toolchain = configuration[:toolchain]

      source_files = expand_sources(configuration.fetch(:sources, []), configuration.fetch(:excludes, []))
      @toolchains = {@default_toolchain => source_files}

      @tests = expand_tests(configuration.fetch(:tests, []))
		end

    def add_sources(sources, excludes=[], toolchain)
      toolchain_sources = []
      toolchain_sources = @toolchains[toolchain] if @toolchains.has_key?toolchain
      toolchain_sources |= expand_sources(sources, excludes)
      @toolchains[toolchain] = toolchain_sources
    end

    def configure_tasks
      super
      @toolchains.each do |toolchain, sources|
        toolchain.output_folder = @output_folder
        toolchain.project_folder = @project_folder
        CompiledConfiguration.add_framework_dependencies_to_toolchain(toolchain, @dependencies)
      end
    end

    private

    def check_configuration(configuration)
      fail "No toolchain specified for #{@project_name}:#{@configuration_name}" if configuration.fetch(:toolchain, nil).nil?
    end

    def expand_sources(sources, excludes)
      source_files = FileList.new()

      sources = [sources] unless sources.respond_to?(:to_ary)
      sources = sources.collect {|s| File.join(@project_folder,s)}
      source_files.include(sources)

      excludes = [excludes] unless excludes.respond_to?(:to_ary)
      excludes = excludes.collect {|e| File.join(@project_folder,e)}
      source_files.exclude(excludes)

      return source_files.to_ary.collect {|s| File.expand_path(s)}
    end

    def expand_tests(tests)
      tests = [tests] unless tests.respond_to?(:to_ary)
      return tests
    end

    def self.add_framework_dependencies_to_toolchain(toolchain, *dependencies)
      dependencies.each do |dependency|
        if dependency.respond_to? :to_ary
          CompiledConfiguration.add_framework_dependencies_to_toolchain(toolchain, *dependency.to_ary)
        else
          task_dependency = Rake.application.lookup(dependency)
          toolchain.add_include_paths(task_dependency.api_headers) if task_dependency.respond_to? :api_headers
          toolchain.add_include_objects(task_dependency.library_files) if task_dependency.respond_to? :library_files
        end
      end
    end

    include Rake::DSL
	end

end
