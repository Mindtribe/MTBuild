module MTBuild
  require 'MTBuild/Configuration'

	class CompiledConfiguration < Configuration

    attr_reader :dependencies
    attr_reader :include_paths
    attr_reader :output_folder
    attr_reader :project_folder
    attr_reader :source_files
    attr_reader :toolchain

		def initialize(project_name, configuration_name, configuration)
      super
      check_configuration(configuration)

      @dependencies = configuration.fetch(:dependencies, [])
      @include_paths = configuration.fetch(:include_paths, [])
      @output_folder = File.join(MTBuild.build_folder, @project_name.to_s, @configuration_name.to_s)
      @project_folder = configuration[:project_folder]
      @source_files = expand_sources(configuration.fetch(:sources, []), configuration.fetch(:excludes, []))

      @toolchain = configuration[:toolchain]
      @toolchain.output_folder = @output_folder
      #@toolchain.project_folder = project_folder
      @toolchain.add_include_paths(@include_paths)
		end

    def configure_tasks
    end

    private

    def check_configuration(configuration)
      fail "No project folder specified for #{@project_name}:#{@configuration_name}" if configuration.fetch(:project_folder, nil).nil?
      fail "No toolchain specified for #{@project_name}:#{@configuration_name}" if configuration.fetch(:toolchain, nil).nil?
    end

    def expand_sources(sources, excludes)
      source_file_map = []

      source_files = FileList.new()
      # Sources is a string or an array of strings. These could represent one file or
      # a file pattern. Use FileList to expand these into files.
      sources = [sources] if sources.is_a?(String)
      sources.each do |source|
        source_files.include(File.join(@project_folder,source))
      end

      excludes = [excludes] if excludes.is_a?(String)
      excludes.each do |exclude|
        source_files.exclude(File.join(@project_folder,exclude))
      end

      # Map each source file to an appropriate output folder. The output folder is
      # determined by the project's output folder and the source's location within the project.
      # a file pattern. Use FileList to expand these into files.
      source_files.each do |source|
        relative_source_location = Utils::path_difference(@project_folder, File.dirname(source))
        fail "Source file #{source} must be within #{@project_folder}." if relative_source_location.nil?
        source_output_folder = File.join(@output_folder, relative_source_location)
        source_file_map << [source, source_output_folder]
      end

      return source_file_map
    end

    include Rake::DSL
	end

end
