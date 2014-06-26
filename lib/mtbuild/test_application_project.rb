module MTBuild
  require "mtbuild/test_application_configuration"
  require 'mtbuild/project'

  # This class is used to build test applications. A test application has
  # compilation and link phases that produce a binary test executable. The test
  # executable is invoked after building successfully.
  class TestApplicationProject < Project

    # Adds a named test application configuration to the project.
    def add_configuration(configuration_name, configuration)
      super
      default_configuration = Workspace.configuration_defaults.fetch(configuration_name, {})
      merged_configuration = Utils.merge_configurations(default_configuration, configuration)
      cfg = TestApplicationConfiguration.new(@project_name, @project_folder, effective_output_folder, configuration_name, merged_configuration)
      @configurations << cfg
      return cfg
    end

  end

end
