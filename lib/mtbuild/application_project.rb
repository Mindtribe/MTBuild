module MTBuild
  require "mtbuild/application_configuration"
  require 'mtbuild/project'

	class ApplicationProject < Project

    def add_configuration(configuration_name, configuration)
      cfg = ApplicationConfiguration.new(@project_name, @project_folder, configuration_name, configuration)
      @configurations << cfg
      return cfg
    end

	end

end
