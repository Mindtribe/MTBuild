module MTBuild

  # This is the base class for all project types.
  class Project
    require 'mtbuild/build_registry'

    # The project's name
    attr_reader :project_name

    # The project's folder. Relative path references are interpreted as
    # relative to this folder.
    attr_reader :project_folder

    # The project's output folder. Project output goes here.
    attr_reader :output_folder

    # The project's parent workspace
    attr_reader :parent_workspace

    # If supplied, the configuration_block will be passed the
    # newly-constructed Project object.
    def initialize(project_name, project_folder, &configuration_block)
      @configurations = []
      @project_folder = File.expand_path(project_folder)
      @output_folder = File.expand_path(File.join(@project_folder, MTBuild.default_output_folder))
      @project_name, @parent_workspace = MTBuild::BuildRegistry.enter_project(project_name, self)

      configuration_block.call(self) if configuration_block

      namespace @project_name do
        @configurations.each do |configuration|
          configuration.configure_tasks
        end
      end

      #TODO: This is a strange way to do this. Should probably be moved to "application" functionality.
      if @parent_workspace.nil? and Rake.application.lookup(:default).nil?
        task :default do
          puts 'Nothing to do. Use the -T flag to see the list of tasks you can build.'
        end
      end

      MTBuild::BuildRegistry.exit_project
    end

    # Get the fully-qualified task name for a configuration
    def task_for_configuration(config_name)
      "#{@project_name}:#{config_name}"
    end

    # Set the project's output folder.
    def set_output_folder(output_folder)
      @output_folder = File.expand_path(File.join(@project_folder, output_folder))
    end

    # Returns the effective output folder. If a workspace exists, this will
    # return the workspace's output folder. If not, it will return the
    # project's output folder.
    def effective_output_folder
      if MTBuild::BuildRegistry.top_workspace.nil?
        File.join(@output_folder, @project_name.to_s.split(':'))
      else
        File.join(MTBuild::BuildRegistry.top_workspace.output_folder, @project_name.to_s.split(':'))
      end
    end

    private

    def add_configuration(configuration_name, configuration)
    end

    include Rake::DSL
  end

end
