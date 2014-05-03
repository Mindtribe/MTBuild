module MTBuild
  require "mtbuild/test_application_configuration"
  require 'mtbuild/project'

	class TestApplicationProject < Project

    def add_configuration(configuration_name, configuration)
      @configurations << TestApplicationConfiguration.new(@project_name, @project_folder, configuration_name, configuration)
    end

	end

end
