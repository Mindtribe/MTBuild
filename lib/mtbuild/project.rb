module MTBuild

	class Project

    attr_reader :project_name
    attr_reader :project_folder
    attr_reader :output_folder

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

    def add_default_tasks(default_tasks)
      @default_tasks |= Utils.ensure_array(default_tasks).flatten
    end

    def set_output_folder(output_folder)
      @output_folder = File.expand_path(File.join(@project_folder, output_folder))
    end

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

    def create_configuration_tasks(configuration_name, configuration)
      check_configuration(configuration_name, configuration)
    end

    include Rake::DSL
	end

end
