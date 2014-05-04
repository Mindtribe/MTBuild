module MTBuild
  require "mtbuild/test_application_configuration"
  require 'mtbuild/project'

	class TestApplicationProject < Project

    def add_configuration(configuration_name, configuration)
      cfg = TestApplicationConfiguration.new(@project_name, @project_folder, configuration_name, configuration)
      @configurations << cfg
      return cfg
    end

	end

end
