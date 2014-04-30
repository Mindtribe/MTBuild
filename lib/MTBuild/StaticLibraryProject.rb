require 'MTBuild/Project'
require 'MTBuild/Utils'

module MTBuild

  require 'rake/clean'

	class StaticLibraryProject < Project

    private

    def create_configuration_tasks(configuration_name, configuration)
      super

      output_folder = File.join(MTBuild.build_folder,@name.to_s,configuration_name.to_s)

      toolchain = configuration[:toolchain]
      toolchain.output_folder = output_folder

      source_file_map = expand_sources(configuration.fetch(:sources, []), configuration[:project_folder], output_folder)
      object_files = toolchain.create_compile_tasks(source_file_map)
      library_file = toolchain.create_static_library_tasks(object_files, @name)
      new_task = static_library_task configuration_name => library_file do |t|
        puts "built library #{t.name}."
      end
      new_task.api_headers = configuration.fetch(:api_headers, nil)
      new_task.library_binary = library_file
    end

	end

end
