module MTBuild

  # This is the base class for all project types.
	class Project

    # The project's name
    attr_reader :project_name

    # The project's folder. Relative path references are interpreted as
    # relative to this folder.
    attr_reader :project_folder

    # The project's output folder. Project output goes here.
    attr_reader :output_folder

    # If supplied, the configuration_block will be passed the
    # newly-constructed Project object.
		def initialize(project_name, project_folder, &configuration_block)
      @configurations = []
      @default_tasks = []
      @project_name = project_name
      @project_folder = File.expand_path(project_folder)
      @output_folder = File.expand_path(File.join(@project_folder, MTBuild.default_output_folder))
			configuration_block.call(self) if configuration_block

      namespace @project_name do
        @configurations.each do |configuration|
          configuration.configure_tasks()
        end
      end

      # If there is no active workspace, set up any registered default project tasks
      task :default => @default_tasks unless Workspace.have_workspace?
		end

    # Add tasks to be built by default if MTBuild is invoked with no arguments
    def add_default_tasks(default_tasks)
      @default_tasks |= Utils.ensure_array(default_tasks).flatten
    end

    # Set the project's output folder.
    def set_output_folder(output_folder)
      @output_folder = File.expand_path(File.join(@project_folder, output_folder))
    end

    # Returns the effective output folder. If a workspace exists, this will
    # return the workspace's output folder. If not, it will return the
    # project's output folder.
    def effective_output_folder
      if Workspace.have_workspace?
        relative_project_location = Utils::path_difference(Workspace.workspace.workspace_folder, @project_folder)
        fail "Project folder '#{@project_folder}' must be within workspace folder '#{Workspace.workspace.workspace_folder}'." if relative_project_location.nil?
        return File.join(Workspace.workspace.output_folder, relative_project_location)
      else
        return @output_folder
      end
    end

    private

    def add_configuration(configuration_name, configuration)
    end

    include Rake::DSL
	end

end
