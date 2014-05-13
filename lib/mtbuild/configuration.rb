module MTBuild

  require 'mtbuild/versioner'

	class Configuration

    attr_reader :project_name
    attr_reader :project_folder
    attr_reader :output_folder
    attr_reader :configuration_name

		def initialize(project_name, project_folder, output_folder, configuration_name, configuration)
      check_configuration(configuration)
      @project_name = project_name
      @project_folder = File.expand_path(project_folder)
      @configuration_name = configuration_name
      @output_folder = File.expand_path(File.join(output_folder, @project_name.to_s, @configuration_name.to_s))

      @versioner = nil
      @versioner_config = configuration.fetch(:versioner, nil)
      @versioner = Versioner.create_versioner(@project_name, @project_folder, @output_folder, @configuration_name, @versioner_config) unless @versioner_config.nil?
		end

    def configure_tasks
      @versioner.create_version_tasks unless @versioner.nil?
    end

    private

    def check_configuration(configuration)
    end

    include Rake::DSL
	end

end
