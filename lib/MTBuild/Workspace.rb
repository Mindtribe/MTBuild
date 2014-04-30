module MTBuild

	class Workspace

    attr_reader :name

		def initialize(workspace_name, &configuration_block)
      @name = workspace_name
      @projects = []
			configuration_block.call(self) if configuration_block

      @projects.each do |project|
        require project
      end

      task :all do
        puts "built workspace #{@name}"
      end

      task :default => :all
		end

    def add_project(project_location)
      new_projects = []
      Dir[File.join(Rake.original_dir,project_location)].each do |project_path|
        if File.directory?(project_path)
          project_rakefile = File.join(project_path,'Rakefile')
          new_projects << project_rakefile
        end
      end
      MTBuild.logger.warn "Could not find a valid project at '#{project_location}'. Ignored." if new_projects.empty?
      @projects += new_projects
    end

    include Rake::DSL

	end

end
