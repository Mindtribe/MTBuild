module MTBuild
  require "mtbuild/application_configuration"
  require 'mtbuild/project'

  # This class is used to build applications. An application has compilation
  # and link phases that produce a binary executable.
  class ApplicationProject < Project

    private

    # Create an application configuration
    def create_configuration(configuration_name, configuration)
      ApplicationConfiguration.new(self, effective_output_folder, configuration_name, configuration)
    end

  end

end
