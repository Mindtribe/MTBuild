module MTBuild
  require 'mtbuild/compiled_configuration'

  # Use this class to create test application configurations. You won't typically
  # instantiate this directly. Instead, the TestApplicationProject.add_configuration
  # method will create this for you.
	class TestApplicationConfiguration < CompiledConfiguration

    # Create the actual Rake tasks that will perform the configuration's work
    def configure_tasks
      super
      all_object_files = []
      all_object_folders = []
      @toolchains.each do |toolchain, sources|
        object_files, object_folders = toolchain.create_compile_tasks(sources)
        all_object_files |= object_files
        all_object_folders |= object_folders
      end

      application_binaries, application_files, application_folders = @default_toolchain.create_application_tasks(all_object_files, @project_name)
      dependencies = @dependencies+all_object_folders+application_folders+application_files+application_binaries

      desc "Build and run test application '#{@project_name}' with configuration '#{@configuration_name}'"
      new_task = test_application_task @configuration_name => dependencies do |t|
        puts "built test application #{t.name}."
        sh application_binaries.first
        puts "ran test application #{t.name}."
      end
    end

	end

end
