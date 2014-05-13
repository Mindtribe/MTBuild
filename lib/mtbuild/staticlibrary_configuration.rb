module MTBuild
  require 'mtbuild/compiled_configuration'

	class StaticLibraryConfiguration < CompiledConfiguration

    attr_reader :api_headers

    def initialize(project_name, project_folder, output_folder, configuration_name, configuration)
      super
      @api_headers = Utils.expand_folder_list(configuration.fetch(:api_headers, []), @project_folder)
    end

    def configure_tasks
      super
      all_object_files = []
      all_object_folders = []
      @toolchains.each do |toolchain, sources|
        toolchain.add_include_paths(@api_headers)
        object_files, object_folders = toolchain.create_compile_tasks(sources)
        all_object_files |= object_files
        all_object_folders |= object_folders
      end

      library_files, library_folders = @default_toolchain.create_static_library_tasks(all_object_files, @project_name)
      dependencies = @dependencies+all_object_folders+library_folders+library_files

      desc "Build library '#{@project_name}' with configuration '#{@configuration_name}'"
      new_task = static_library_task @configuration_name => dependencies do |t|
        puts "built library #{t.name}."
        @tests.each do |test|
          if Rake::Task.task_defined? test
            Rake::Task[test].invoke
          else
            $stderr.puts "warning: Skipping unknown test '#{test}'"
          end
        end
      end
      new_task.api_headers = @api_headers
      new_task.library_files = library_files
    end

	end

end
