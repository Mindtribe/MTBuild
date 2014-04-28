module MTBuild

	class Workspace

    attr_reader :name

		def initialize(workspace_name, &configuration_block)
      @name = workspace_name
      @projects = []
			configuration_block.call(self) if configuration_block

      @projects.each do |project| require project end

      task :all do
        puts "built #{@name}"
      end

      task :default => :all
		end

    def add_project(project_location)
      project_rakefile = File.join(Rake.original_dir,project_location,'Rakefile')
      @projects << project_rakefile
    end

    include Rake::DSL

	end

end
