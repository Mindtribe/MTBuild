module MTBuild

	class Project

    attr_reader :name

		def initialize(project_name, &configuration_block)
      @configurations = []
      @name = project_name
			configuration_block.call(self) if configuration_block

      namespace @name do
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
