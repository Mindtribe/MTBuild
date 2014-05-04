module MTBuild
  require "mtbuild/staticlibrary_configuration"
  require 'mtbuild/project'

	class StaticLibraryProject < Project

    def add_configuration(configuration_name, configuration)
      cfg = StaticLibraryConfiguration.new(@project_name, @project_folder, configuration_name, configuration)
      @configurations << cfg
      return cfg
    end

	end

end
