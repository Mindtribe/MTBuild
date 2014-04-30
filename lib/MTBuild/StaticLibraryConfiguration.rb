module MTBuild
  require 'MTBuild/CompiledConfiguration'

	class StaticLibraryConfiguration < CompiledConfiguration

    attr_reader :api_headers

    def initialize(project_name, configuration_name, configuration)
      super
      @api_headers = expand_api_headers(configuration.fetch(:api_headers, []))
    end

    def configure_tasks
      super
      object_files = @toolchain.create_compile_tasks(source_files)
      library_file = @toolchain.create_static_library_tasks(object_files, @project_name)
      new_task = static_library_task @configuration_name => library_file do |t|
        puts "built library #{t.name}."
      end
      new_task.api_headers = @api_headers
      new_task.library_binary = library_file
    end

    private

    def expand_api_headers(header_path_patterns)
      api_header_paths = []

      header_path_patterns = [header_path_patterns] if header_path_patterns.is_a?(String)
      header_path_patterns.each do |header_path_pattern|
        Dir[File.join(@project_folder, header_path_pattern)].each do |header_path|
          api_header_paths << header_path if File.directory?(header_path)
        end
      end
      return api_header_paths
    end

	end

end
