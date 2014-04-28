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

    include Rake::DSL
	end

end
