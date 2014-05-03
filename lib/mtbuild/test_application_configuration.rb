module MTBuild
  require 'mtbuild/compiled_configuration'

	class TestApplicationConfiguration < CompiledConfiguration

    def initialize(project_name, project_folder, configuration_name, configuration)
      super
    end

    def configure_tasks
      super
      object_files, object_folders = @toolchain.create_compile_tasks(source_files)
      application_binary, application_files, application_folders = @toolchain.create_application_tasks(object_files, @project_name)
      dependencies = @dependencies+object_folders+application_folders+application_files+[application_binary]
      new_task = application_task @configuration_name => dependencies do |t|
        puts "built test application #{t.name}."
        sh application_binary
        puts "ran test application #{t.name}."
      end
      new_task.add_description("Build and run test application '#{@project_name}' with configuration '#{@configuration_name}'")
    end

	end

end
