require 'MTBuild/Project'
require 'MTBuild/Utils'

module MTBuild
  require "MTBuild/StaticLibraryConfiguration"
  require 'MTBuild/Project'

	class StaticLibraryProject < Project

    def add_configuration(configuration_name, configuration)
      @configurations << StaticLibraryConfiguration.new(@name,configuration_name,configuration)
    end

	end

end
