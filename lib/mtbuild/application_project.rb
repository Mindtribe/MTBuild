module MTBuild
  require "mtbuild/application_configuration"
  require 'mtbuild/project'

	class ApplicationProject < Project

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
