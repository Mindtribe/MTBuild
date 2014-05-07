module MTBuild

	class Workspace
    require 'mtbuild/utils'
    require 'rake/clean'

    attr_reader :workspace_name
    attr_reader :workspace_folder
    attr_reader :output_folder

		def initialize(workspace_name, workspace_folder, &configuration_block)
      @workspace_name = workspace_name
      @workspace_folder = File.expand_path(workspace_folder)
      @output_folder = File.expand_path(File.join(@workspace_folder, MTBuild.default_outpout_folder))
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

    def add_project(project_location)
      new_projects = []
      Utils.expand_folder_list(project_location, Rake.original_dir).each do |project_path|
        if File.directory? project_path
          project_rakefile = File.join(project_path,'Rakefile.rb')
          new_projects << project_rakefile if File.file? project_rakefile
        end
      end
      $stderr.puts "Could not find a valid project at '#{project_location}'. Ignored." if new_projects.empty?
      @projects += new_projects
    end

    def add_default_tasks(default_tasks)
      @default_tasks |= Utils.ensure_array(default_tasks).flatten
    end

    def set_configuration_defaults(configuration_name, defaults_hash)
      Workspace.set_configuration_defaults(configuration_name, defaults_hash)
    end

    def set_output_folder(output_folder)
      @output_folder = File.expand_path(File.join(@workspace_folder,output_folder))
    end

    @workspace = nil

    def self.workspace
      return @workspace
    end

    def self.set_workspace(workspace)
      @workspace = workspace
    end

    def self.have_workspace?
      return !@workspace.nil?
    end

    def self.add_default_tasks(default_tasks)
      @workspace.add_default_tasks(default_tasks) unless @workspace.nil?
    end

    @configuration_defaults = {}

    def self.configuration_defaults
      return @configuration_defaults
    end

    def self.set_configuration_defaults(configuration_name, defaults_hash)
      @configuration_defaults[configuration_name] = defaults_hash
    end

    include Rake::DSL

	end

end
