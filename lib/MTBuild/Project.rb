module MTBuild

	class Project

    attr_reader :name

		def initialize(project_name, &configuration_block)
      @configurations = []
      @name = project_name
			configuration_block.call(self) if configuration_block

      namespace @name do
        @configurations.each do |config|
          create_configuration_tasks(config.keys.first, config.values.first)
        end
      end
		end

    def add_configuration(configuration_name, configuration)
      @configurations << {configuration_name => configuration}
    end

    private

    def check_configuration(configuration_name, configuration)
      fail "No project folder specified for #{@name}:#{configuration_name}" if configuration.fetch(:project_folder, nil).nil?
      fail "No build folder specified for #{@name}:#{configuration_name}" if configuration.fetch(:project_folder, nil).nil?
      fail "No toolchain specified for #{@name}:#{configuration_name}" if configuration.fetch(:toolchain, nil).nil?
    end

    def create_configuration_tasks(configuration_name, configuration)
      check_configuration(configuration_name, configuration)
    end

    def expand_sources(sources, project_folder, output_folder)
      source_file_map = []

      source_files = []
      # Sources is a string or an array of strings. These could represent one file or
      # a file pattern. Use FileList to expand these into files.
      sources = [sources] if sources.is_a?(String)
      sources.each do |source|
        source_files += FileList[File.join(project_folder,source)].to_a
      end

      # Map each source file to an appropriate output folder. The output folder is
      # determined by the project's output folder and the source's location within the project.
      # a file pattern. Use FileList to expand these into files.
      source_files.each do |source|
        relative_source_location = Utils::path_difference(project_folder, File.dirname(source))
        fail "Source file #{source} must be within #{project_folder}." if relative_source_location.nil?
        source_output_folder = File.join(output_folder, relative_source_location)
        source_file_map << [source, source_output_folder]
      end

      return source_file_map
    end

    include Rake::DSL
	end

end
