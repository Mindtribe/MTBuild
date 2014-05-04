module MTBuild
  require 'mtbuild/compiled_configuration'

	class ApplicationConfiguration < CompiledConfiguration

    def initialize(project_name, project_folder, configuration_name, configuration)
      super
    end

    def configure_tasks
      super
      all_object_files = []
      all_object_folders = []
      @toolchains.each do |toolchain, sources|
        object_files, object_folders = toolchain.create_compile_tasks(sources)
        all_object_files |= object_files
        all_object_folders |= object_folders
      end

      application_binary, application_files, application_folders = @default_toolchain.create_application_tasks(all_object_files, @project_name)
      dependencies = @dependencies+all_object_folders+application_folders+application_files+[application_binary]
      new_task = application_task @configuration_name => dependencies do |t|
        puts "built application #{t.name}."
      end
      new_task.add_description("Build application '#{@project_name}' with configuration '#{@configuration_name}'")
    end

	end

end
