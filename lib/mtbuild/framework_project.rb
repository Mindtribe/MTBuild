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

    # Specifies API header locations
    def add_api_headers(api_headers)
      @api_headers += Utils.expand_folder_list(api_headers, @project_folder)
    end

    private

    # Create a framework configuration
    def create_configuration(configuration_name, configuration)
      FrameworkConfiguration.new(self, effective_output_folder, configuration_name, configuration, @api_headers)
    end

  end

end
