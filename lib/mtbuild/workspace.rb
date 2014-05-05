module MTBuild

	class Workspace
    require 'rake/clean'

    attr_reader :name

		def initialize(workspace_name, &configuration_block)
      @name = workspace_name
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

        CLOBBER.include(MTBuild.build_folder)

        task :workspace do
          puts "built workspace #{@name}"
        end

        task :default => @default_tasks+[:workspace]
      end
		end

    def add_project(project_location)
      new_projects = []
      Dir[File.join(Rake.original_dir,project_location)].each do |project_path|
        if File.directory? project_path
          project_rakefile = File.join(project_path,'Rakefile.rb')
          new_projects << project_rakefile if File.file? project_rakefile
        end
      end
      $stderr.puts "Could not find a valid project at '#{project_location}'. Ignored." if new_projects.empty?
      @projects += new_projects
    end

    def add_default_tasks(default_tasks)
      default_tasks = [default_tasks] unless default_tasks.respond_to? :to_ary
      @default_tasks |= default_tasks.flatten
    end


    @workspace = nil

    def self.workspace
      return @workspace
    end

    def self.set_workspace(workspace)
      @workspace = workspace
    end

    def self.add_default_tasks(default_tasks)
      @workspace.add_default_tasks(default_tasks) unless @workspace.nil?
    end

    include Rake::DSL

	end

end
