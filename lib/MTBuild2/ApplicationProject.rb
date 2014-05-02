module MTBuild
  require "MTBuild/ApplicationConfiguration"
  require 'MTBuild/Project'

	class ApplicationProject < Project

    def add_configuration(configuration_name, configuration)
      @configurations << ApplicationConfiguration.new(@name,configuration_name,configuration)
    end

	end

end
