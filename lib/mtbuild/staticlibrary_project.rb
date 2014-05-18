module MTBuild
  require "mtbuild/staticlibrary_configuration"
  require 'mtbuild/project'

  # This class is used to build static libraries. A static library has
  # compilation and archival phases that produce a binary library package.
	class StaticLibraryProject < Project

    # Adds a named static library configuration to the project.
    def add_configuration(configuration_name, configuration)
      super
      default_configuration = Workspace.configuration_defaults.fetch(configuration_name, {})
      merged_configuration = Utils.merge_configurations(default_configuration, configuration)
      cfg = StaticLibraryConfiguration.new(@project_name, @project_folder, effective_output_folder, configuration_name, merged_configuration)
      @configurations << cfg
      return cfg
    end

	end

end
