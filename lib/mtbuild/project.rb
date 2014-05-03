module MTBuild

	class Project

    attr_reader :project_name, :project_folder

		def initialize(project_name, project_folder, &configuration_block)
      @configurations = []
      @project_name = project_name
      @project_folder = project_folder
			configuration_block.call(self) if configuration_block

      namespace @project_name do
        @configurations.each do |configuration|
          configuration.configure_tasks()
        end
      end
		end

    private

    def add_configuration(configuration_name, configuration)
    end

    def create_configuration_tasks(configuration_name, configuration)
      check_configuration(configuration_name, configuration)
    end

    include Rake::DSL
	end

end
