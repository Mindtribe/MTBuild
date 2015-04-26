module MTBuild

  # Use this class to create a workspace
  class Workspace
    require 'mtbuild/utils'
    require 'rake/clean'

    # The workspace's name
    attr_reader :workspace_name

    # The workspace's folder. Relative path references are interpreted as
    # relative to this folder.
    attr_reader :workspace_folder

    # The workspace's output folder
    attr_reader :output_folder

    def initialize(workspace_name, workspace_folder, &configuration_block)
      @workspace_name = workspace_name
      @workspace_folder = File.expand_path(workspace_folder)
      @output_folder = File.expand_path(File.join(@workspace_folder, MTBuild.default_output_folder))
      @projects = []
      @default_tasks = []

      # Only process the first workspace found.
      # Subsequent workspaces will be ignored
      if MTBuild::Workspace.workspace.nil?
        MTBuild::Workspace.set_workspace(self)

        configuration_block.call(self) if configuration_block

        @projects.each do |project|
          require project
        end

        CLOBBER.include(@output_folder)

        task :workspace do
          puts "built workspace #{@workspace_name}"
        end

        task :default => @default_tasks+[:workspace]
      end
    end

    # Adds a project subfolder
    def add_project(project_location)
      new_projects = []
      Utils.expand_folder_list(project_location, Rake.original_dir).each do |project_path|
        if File.directory? project_path
          project_rakefile = MTBuild::Workspace.find_mtbuildfile(project_path)
          new_projects << project_rakefile unless project_rakefile.nil?
        end
      end
      $stderr.puts "Could not find a valid project at '#{project_location}'. Ignored." if new_projects.empty?
      @projects += new_projects
    end

    # Adds tasks to be run by default when MTBuild is invoked with no arguments.
    def add_default_tasks(default_tasks)
      @default_tasks |= Utils.ensure_array(default_tasks).flatten
    end

    # Sets defaults for all configurations with the specified name
    def set_configuration_defaults(configuration_name, defaults_hash)
      Workspace.set_configuration_defaults(configuration_name, defaults_hash)
    end

    # Sets the build output folder location
    def set_output_folder(output_folder)
      @output_folder = File.expand_path(File.join(@workspace_folder,output_folder))
    end

    @workspace = nil

    # The singleton workspace instance
    def self.workspace
      return @workspace
    end

    # Sets the singleton workspace instance
    def self.set_workspace(workspace)
      @workspace = workspace
    end

    # Queries whether a workspace exists
    def self.have_workspace?
      return !@workspace.nil?
    end

    # Add default tasks to the singleton workspace instance
    def self.add_default_tasks(default_tasks)
      @workspace.add_default_tasks(default_tasks) unless @workspace.nil?
    end

    @configuration_defaults = {}

    # Gets the singleton configuration defaults
    def self.configuration_defaults
      return @configuration_defaults
    end

    # Adds or updates defaults to the singleton configuration defaults
    def self.set_configuration_defaults(configuration_name, defaults_hash)
      @configuration_defaults[configuration_name] = defaults_hash
    end

    def self.find_mtbuildfile(project_path)
      Rake.application.rakefiles.each do |fn|
        mtbuildfile = File.join(project_path, fn)
        if File.file? mtbuildfile
          return mtbuildfile
        end
      end
      return nil
    end

    include Rake::DSL

  end

end
