module MTBuild
  require 'MTBuild/CompiledConfiguration'

	class StaticLibraryConfiguration < CompiledConfiguration

    attr_reader :api_headers

    def initialize(project_name, configuration_name, configuration)
      super
      @api_headers = configuration.fetch(:api_headers, nil)
    end

    def configure_tasks
      super
      object_files = @toolchain.create_compile_tasks(source_files)
      library_file = @toolchain.create_static_library_tasks(object_files, @name)
      new_task = static_library_task @configuration_name => library_file do |t|
        puts "built library #{t.name}."
      end
      new_task.api_headers = api_headers
      new_task.library_binary = library_file
    end

	end

end
