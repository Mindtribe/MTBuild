module MTBuild
  require "mtbuild/application_configuration"
  require 'mtbuild/project'

  # This class is used to build applications. An application has compilation
  # and link phases that produce a binary executable.
	class ApplicationProject < Project

    # Adds a named ApplicationConfiguration to the project.
    def add_configuration(configuration_name, configuration)
      super
      default_configuration = Workspace.configuration_defaults.fetch(configuration_name, {})
      merged_configuration = Utils.merge_configurations(default_configuration, configuration)
      cfg = ApplicationConfiguration.new(@project_name, @project_folder, effective_output_folder, configuration_name, merged_configuration)
      @configurations << cfg
      return cfg
    end

	end

end
