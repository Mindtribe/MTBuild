module MTBuild
  require "mtbuild/test_application_configuration"
  require 'mtbuild/project'

  # This class is used to build test applications. A test application has
  # compilation and link phases that produce a binary test executable. The test
  # executable is invoked after building successfully.
  class TestApplicationProject < Project

    private

    # Create a test application configuration
    def create_configuration(configuration_name, configuration)
      TestApplicationConfiguration.new(self, effective_output_folder, configuration_name, configuration)
    end


  end

end
