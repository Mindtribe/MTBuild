module MTBuild
  require "mtbuild/framework_configuration"
  require 'mtbuild/project'

  # This class is used to load frameworks. A framework provides precompiled
  # objects/libraries and API headers. Listing a framework as a dependency in
  # an application will automatically include the framework's API headers and
  # link with its objects/libraries
  class FrameworkProject < Project

    def initialize(project_name, project_folder, &configuration_block)
      @api_headers = []
      super
    end

    # Adds a named FrameworkConfiguration to the project.
    def add_configuration(configuration_name, configuration)
      super
      default_configuration = Workspace.configuration_defaults.fetch(configuration_name, {})
      merged_configuration = Utils.merge_configurations(default_configuration, configuration)
      cfg = FrameworkConfiguration.new(@project_name, @project_folder, effective_output_folder, configuration_name, merged_configuration, @api_headers)
      @configurations << cfg
      return cfg
    end

    # Specifies API header locations
    def add_api_headers(api_headers)
      @api_headers += Utils.expand_folder_list(api_headers, @project_folder)
    end

  end

end
