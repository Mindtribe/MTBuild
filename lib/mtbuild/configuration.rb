module MTBuild

	class Configuration

    attr_reader :project_name
    attr_reader :project_folder
    attr_reader :configuration_name

		def initialize(project_name, project_folder, configuration_name, configuration)
      check_configuration(configuration)
      @project_name = project_name
      @project_folder = project_folder
      @configuration_name = configuration_name
		end

    def configure_tasks
    end

    private

    def check_configuration(configuration)
    end

    include Rake::DSL
	end

end
