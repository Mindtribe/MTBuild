module MTBuild
  require "mtbuild/staticlibrary_configuration"
  require 'mtbuild/project'

	class StaticLibraryProject < Project

    def add_configuration(configuration_name, configuration)
      @configurations << StaticLibraryConfiguration.new(@name,configuration_name,configuration)
    end

	end

end
