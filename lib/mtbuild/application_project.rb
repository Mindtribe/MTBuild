module MTBuild
  require "mtbuild/application_configuration"
  require 'mtbuild/project'

	class ApplicationProject < Project

    def add_configuration(configuration_name, configuration)
      @configurations << ApplicationConfiguration.new(@name,configuration_name,configuration)
    end

	end

end
