module MTBuild
  require 'MTBuild/CompiledConfiguration'

	class ApplicationConfiguration < CompiledConfiguration

    def initialize(project_name, configuration_name, configuration)
      super
    end

    def configure_tasks
      super
      object_files, object_folders = @toolchain.create_compile_tasks(source_files)
      application_files, application_folders = @toolchain.create_application_tasks(object_files, @project_name)
      dependencies = @dependencies+object_folders+application_folders+application_files
      new_task = application_task @configuration_name => dependencies do |t|
        puts "built application #{t.name}."
      end
    end

	end

end
