module MTBuild
  require 'MTBuild/CompiledConfiguration'

	class ApplicationConfiguration < CompiledConfiguration

    def initialize(project_name, configuration_name, configuration)
      super
    end

    def configure_tasks
      super
      object_files = @toolchain.create_compile_tasks(source_files)
      executable_file = @toolchain.create_executable_tasks(object_files, @project_name)
      depends = @dependencies+[executable_file]
      new_task = application_task @configuration_name => depends do |t|
        puts "built application #{t.name}."
      end
    end

	end

end
