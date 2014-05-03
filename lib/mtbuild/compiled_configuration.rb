module MTBuild
  require 'mtbuild/configuration'

	class CompiledConfiguration < Configuration

    attr_reader :dependencies
    attr_reader :include_paths
    attr_reader :output_folder
    attr_reader :project_folder
    attr_reader :source_files
    attr_reader :toolchain

		def initialize(project_name, project_folder, configuration_name, configuration)
      super
      check_configuration(configuration)

      @dependencies = configuration.fetch(:dependencies, [])
      @include_paths = configuration.fetch(:include_paths, [])
      @output_folder = File.expand_path(File.join(MTBuild.build_folder, @project_name.to_s, @configuration_name.to_s))
      @source_files = expand_sources(configuration.fetch(:sources, []), configuration.fetch(:excludes, []))

      @toolchain = configuration[:toolchain]
      @toolchain.output_folder = @output_folder
      @toolchain.project_folder = @project_folder
      @toolchain.add_include_paths(@include_paths)

      add_framework_dependencies_to_toolchain(dependencies)
		end

    def configure_tasks
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

    def add_framework_dependencies_to_toolchain(*dependencies)
      dependencies.each do |dependency|
        if dependency.respond_to? :to_ary
          add_framework_dependencies_to_toolchain(*dependency.to_ary)
        else
          task_dependency = Rake.application.lookup(dependency)
          @toolchain.add_include_paths(task_dependency.api_headers) if task_dependency.respond_to? :api_headers
          @toolchain.add_include_objects(task_dependency.library_files) if task_dependency.respond_to? :library_files
        end
      end
    end

    include Rake::DSL
	end

end
