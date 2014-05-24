module MTBuild
  require 'mtbuild/configuration'

  # Use this class to create framework configurations. You won't typically
  # instantiate this directly. Instead, the FrameworkProject.add_configuration
  # method will create this for you.
  class FrameworkConfiguration < Configuration

    def initialize(project_name, project_folder, output_folder, configuration_name, configuration, api_headers)
      super project_name, project_folder, output_folder, configuration_name, configuration
      check_configuration(configuration)
      @api_headers = api_headers
      @configuration_headers = Utils.expand_folder_list(configuration.fetch(:configuration_headers, []), @project_folder)
      @object_files = Utils.expand_file_list(configuration[:objects], [], @project_folder)
    end

    # Create the actual Rake tasks that will perform the configuration's work
    def configure_tasks
      super
      desc "Framework '#{@project_name}' with configuration '#{@configuration_name}'"
      new_task = framework_task @configuration_name => @object_files do |t|
        puts "found framework #{t.name}."
      end
      new_task.api_headers = @api_headers
      new_task.configuration_headers = @configuration_headers
      new_task.library_files = @object_files
    end

    private

    def check_configuration(configuration)
      super
      fail "No objects specified for #{@project_name}:#{@configuration_name}" if configuration.fetch(:objects, nil).nil?
    end

  end

end
