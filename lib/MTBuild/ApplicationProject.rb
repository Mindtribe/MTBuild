require 'MTBuild/Project'

module MTBuild

	class ApplicationProject < Project

    private

    def create_configuration_tasks(configuration_name, configuration)
      super

      output_folder = File.join(MTBuild.build_folder,@name.to_s,configuration_name.to_s)

      toolchain = configuration[:toolchain]
      toolchain.output_folder = output_folder

      source_file_map = expand_sources(configuration.fetch(:sources, []), configuration[:project_folder], output_folder)
      object_files = toolchain.create_compile_tasks(source_file_map)
      executable_file = toolchain.create_executable_tasks(object_files, @name)
      depends = configuration[:dependencies]+[executable_file]
      new_task = application_task configuration_name => depends do |t|
        puts "built application #{t.name}."
      end
    end

	end

end
