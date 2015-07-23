module MTBuild
  require "mtbuild/application_configuration"
  require 'mtbuild/project'

  # This class is used to build applications. An application has compilation
  # and link phases that produce a binary executable.
  class ApplicationProject < Project

    # Adds a named ApplicationConfiguration to the project.
    def add_configuration(configuration_name, configuration)
      super
      default_configuration = {}
      default_configuration = @parent_workspace.configuration_defaults.fetch(configuration_name, {}) unless @parent_workspace.nil?
      merged_configuration = Utils.merge_configurations(default_configuration, configuration)
      cfg = ApplicationConfiguration.new(self, effective_output_folder, configuration_name, merged_configuration)
      @configurations << cfg
      cfg
    end

  end

end
