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

    def initialize(workspace_name, workspace_folder, &configuration_block)
      @workspace_folder = File.expand_path(workspace_folder)
      @output_folder = File.expand_path(File.join(@workspace_folder, MTBuild.default_output_folder))
      @projects = []
      @workspaces = []
      @default_tasks = []
      @configuration_defaults = {}
      @child_workspaces = {}
      @workspace_name, @parent_workspace = MTBuild::BuildRegistry.enter_workspace(workspace_name, self)

      configuration_block.call(self) if configuration_block

      # If there's a parent workspace, use its output folder.
      # Don't use the current workspace's output folder.
      @output_folder = @parent_workspace.output_folder unless @parent_workspace.nil?

      @workspaces.each do |workspace|
        MTBuild::BuildRegistry.expect_workspace
        require workspace
      end

      @projects.each do |project|
        MTBuild::BuildRegistry.expect_project
        require project
      end

      CLOBBER.include(@output_folder)

      task :workspace do
        puts "built workspace #{@workspace_name}"
      end

      task :default => @default_tasks+[:workspace]

      MTBuild::BuildRegistry.exit_workspace
    end

    # Adds a workspace subfolder
    def add_workspace(workspace_location)
      new_workspaces = []
      Utils.expand_folder_list(workspace_location, Rake.original_dir).each do |workspace_path|
        if File.directory? workspace_path
          workspace_rakefile = MTBuild::Workspace.find_build_file(workspace_path)
          new_workspaces << workspace_rakefile unless workspace_rakefile.nil?
        end
      end
      $stderr.puts "Could not find a valid workspace at '#{workspace_location}'. Ignored." if new_workspaces.empty?
      @workspaces += new_workspaces
    end

    # Adds a project subfolder
    def add_project(project_location)
      new_projects = []
      Utils.expand_folder_list(project_location, Rake.original_dir).each do |project_path|
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
      MTBuild::BuildRegistry.last_active_workspace.add_default_rake_tasks(default_tasks) unless MTBuild::BuildRegistry.last_active_workspace.nil?
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

  end

end
