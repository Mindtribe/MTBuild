module MTBuild
  require 'mtbuild/compiled_configuration'

	class StaticLibraryConfiguration < CompiledConfiguration

    attr_reader :api_headers

    def initialize(project_name, project_folder, configuration_name, configuration)
      super
      @api_headers = expand_api_headers(configuration.fetch(:api_headers, []))
    end

    def configure_tasks
      super
      @toolchain.add_include_paths(@api_headers)
      object_files, object_folders = @toolchain.create_compile_tasks(source_files)
      library_files, library_folders = @toolchain.create_static_library_tasks(object_files, @project_name)
      dependencies = @dependencies+object_folders+library_folders+library_files
      new_task = static_library_task @configuration_name => dependencies do |t|
        puts "built library #{t.name}."
      end
      new_task.add_description("Build library '#{@project_name}' with configuration '#{@configuration_name}'")
      new_task.api_headers = @api_headers
      new_task.library_files = library_files
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
