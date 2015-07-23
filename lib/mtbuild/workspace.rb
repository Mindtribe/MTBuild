module MTBuild

  # Use this class to create a workspace
  class Workspace
    require 'mtbuild/utils'
    require 'mtbuild/build_registry'
    require 'rake/clean'

    # The workspace's name
    attr_reader :workspace_name

    # The workspace's folder. Relative path references are interpreted as
    # relative to this folder.
    attr_reader :workspace_folder

    # The workspace's output folder
    attr_reader :output_folder

    # The workspace's parent workspace
    attr_reader :parent_workspace

    # Workspace configuration defaults
    attr_reader :configuration_defaults

    # List of configuration defaults that child workspaces should take from
    # this workspace
    attr_reader :push_configuration_defaults

    # List of default tasks to build with this workspace
    attr_reader :default_tasks

    def initialize(workspace_name, workspace_folder, &configuration_block)
      @workspace_folder = File.expand_path(workspace_folder)
      @output_folder = File.expand_path(File.join(@workspace_folder, MTBuild.default_output_folder))
      @projects = []
      @workspaces = []
      @default_tasks = []
      @configuration_defaults = {}
      @child_workspaces = {}
      @push_configuration_defaults = []
      @workspace_name, @parent_workspace = MTBuild::BuildRegistry.enter_workspace(workspace_name, self)

      unless @parent_workspace.nil?
        pull_configuration_defaults(@parent_workspace, @parent_workspace.push_configuration_defaults)
      end

      configuration_block.call(self) if configuration_block

      # If there's a parent workspace, use its output folder.
      # Don't use the current workspace's output folder.
      @output_folder = @parent_workspace.output_folder unless @parent_workspace.nil?

      @workspaces.each do |workspace|
        MTBuild::BuildRegistry.expect_workspace
        @push_configuration_defaults = workspace[:push_cfg]
        require workspace[:build_file]
        last_workspace = MTBuild::BuildRegistry.reenter_workspace(self)
        unless last_workspace.nil?
          pull_configuration_defaults(last_workspace, workspace[:pull_cfg])
          @default_tasks+=last_workspace.default_tasks if workspace[:pull_tasks]
        end
      end

      @projects.each do |project|
        MTBuild::BuildRegistry.expect_project
        require project
      end

      CLOBBER.include(@output_folder)

      # Only register default tasks if we're the top-level workspace.
      task :default => @default_tasks if @parent_workspace.nil?

      MTBuild::BuildRegistry.exit_workspace
    end

    # Adds a workspace subfolder
    def add_workspace(workspace_location, pull_default_tasks=false, pull_configurations=[], push_configurations=[])
      new_workspaces = []
      Utils.expand_folder_list(workspace_location, @workspace_folder).each do |workspace_path|
        if File.directory? workspace_path
          workspace_rakefile = MTBuild::Workspace.find_build_file(workspace_path)
          unless workspace_rakefile.nil?
            new_workspaces << {
                :build_file=>workspace_rakefile,
                :pull_tasks=>pull_default_tasks,
                :pull_cfg=>pull_configurations,
                :push_cfg=>push_configurations
            }
          end
        end
      end
      $stderr.puts "Could not find a valid workspace at '#{workspace_location}'. Ignored." if new_workspaces.empty?
      @workspaces += new_workspaces
    end

    # Adds a project subfolder
    def add_project(project_location)
      new_projects = []
      Utils.expand_folder_list(project_location, @workspace_folder).each do |project_path|
        if File.directory? project_path
          project_rakefile = MTBuild::Workspace.find_build_file(project_path)
          new_projects << project_rakefile unless project_rakefile.nil?
        end
      end
      $stderr.puts "Could not find a valid project at '#{project_location}'. Ignored." if new_projects.empty?
      @projects += new_projects
    end

    # Adds tasks to be run by default when MTBuild is invoked with no arguments. This method
    # expects only MTBuild tasks and will namespace them according to the current workspace
    # hierarchy.
    def add_default_tasks(default_tasks)
      @default_tasks |= Utils.ensure_array(default_tasks).flatten.collect {|default_task| "#{@workspace_name}:#{default_task}"}
    end

    # Adds Rake tasks to be run by default when MTBuild is invoked with no arguments. This method
    # will not namespace the tasks, so it can be used to specify plain Rake task names.
    def add_default_rake_tasks(default_tasks)
      @default_tasks |= Utils.ensure_array(default_tasks).flatten
    end

    # Sets defaults for all configurations with the specified name
    def set_configuration_defaults(configuration_name, defaults_hash)
      @configuration_defaults[configuration_name] = defaults_hash
    end

    # Sets the build output folder location
    def set_output_folder(output_folder)
      @output_folder = File.expand_path(File.join(@workspace_folder,output_folder))
    end

    # Add default tasks to the last active workspace
    def self.add_default_tasks(default_tasks)
      MTBuild::BuildRegistry.active_workspace.add_default_rake_tasks(default_tasks) unless MTBuild::BuildRegistry.active_workspace.nil?
    end

    def self.find_build_file(project_path)
      Rake.application.rakefiles.each do |fn|
        build_file = File.join(project_path, fn)
        if File.file? build_file
          return build_file
        end
      end
      return nil
    end

    include Rake::DSL

    private

    # pulls specific configuration defaults from a workspace
    def pull_configuration_defaults(workspace, configurations_to_pull)
      configurations_to_pull.each do |configuration_name|
        if workspace.configuration_defaults.has_key?(configuration_name)
          child_config = workspace.configuration_defaults[configuration_name]
          my_config = @configuration_defaults.fetch(configuration_name, {})
          @configuration_defaults[configuration_name] = MTBuild::Utils.merge_configurations(my_config, child_config)
        else
          $stderr.puts "Warning: workspace '#{workspace.workspace_name}' does not have a configuration named #{configuration_name} to retrieve. Ignored."
        end
      end
    end

  end

end
