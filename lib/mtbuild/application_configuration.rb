module MTBuild
  require 'mtbuild/compiled_configuration'
  require 'mtbuild/organized_package_task'

  # Use this class to create application configurations. You won't typically
  # instantiate this directly. Instead, the ApplicationProject.add_configuration
  # method will create this for you.
  class ApplicationConfiguration < CompiledConfiguration

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

      application_binaries, application_files, application_folders = @default_toolchain.create_application_tasks(all_object_files, @parent_project.project_name)
      dependencies = @dependencies+all_object_folders+application_folders+application_files+application_binaries

      desc "Build application '#{@parent_project.project_name}' with configuration '#{@configuration_name}'"
      new_task = application_task @configuration_name => dependencies do |t|
        puts "built application #{t.name}."
        @tests.each do |test|
          if Rake::Task.task_defined? test
            Rake::Task[test].invoke
          else
            $stderr.puts "warning: Skipping unknown test '#{test}'"
          end
        end
      end

      namespace @configuration_name do
        OrganizedPackageTask.new("#{@parent_project.project_name}-#{@configuration_name}", :noversion) do |t|
          t.need_tar_gz = true
          t.add_files_to_folder("", application_binaries+application_files)
        end
      end
      Rake::Task[:"#{@parent_project.project_name}:#{@configuration_name}:package"].prerequisites.insert(0, :"#{@parent_project.project_name}:#{@configuration_name}")

    end

  end

end
