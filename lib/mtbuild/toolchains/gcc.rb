module MTBuild
  require 'mtbuild/cleaner'
  require 'mtbuild/loaders/makefile'
  require 'mtbuild/toolchain'
  require 'mtbuild/utils'

  require 'pathname'

  Toolchain.register_toolchain(:gcc, 'MTBuild::ToolchainGcc')

  # This Toolchain subclass can build using GCC
  class ToolchainGcc < Toolchain

    attr_accessor :cppflags, :cflags, :cxxflags, :asflags, :ldflags, :linker_script

    def initialize(parent_configuration, toolchain_configuration)
      super

      @tracked_folders = []

      begin
        toolchain_test_output=%x{#{compiler_c} --version 2>&1}
        toolchain_test_passed=$?.success?
      rescue
        toolchain_test_passed = false
      end
      fail "Toolchain component #{compiler_c} not found." unless toolchain_test_passed

      @compiler_is_LLVM_gcc = toolchain_test_output.include?'LLVM'
      @link_as_cpp = false
      @cppflags = Utils.ensure_array(toolchain_configuration.fetch(:cppflags, '')).to_a.flatten.join(' ')
      @cflags = Utils.ensure_array(toolchain_configuration.fetch(:cflags, '')).to_a.flatten.join(' ')
      @cxxflags = Utils.ensure_array(toolchain_configuration.fetch(:cxxflags, '')).to_a.flatten.join(' ')
      @asflags = Utils.ensure_array(toolchain_configuration.fetch(:asflags, '')).to_a.flatten.join(' ')
      @ldflags = Utils.ensure_array(toolchain_configuration.fetch(:ldflags, '')).to_a.flatten.join(' ')
      @linker_script = toolchain_configuration.fetch(:linker_script, '')
    end

    def scan_sources(source_files)
      @link_as_cpp = source_files.any? { |s| get_file_type(s)==:cplusplus }
    end

    # Create Rake tasks for compilation
    def create_compile_tasks(source_files)
      object_files = []
      object_folders = []

      source_files.each do |source_file|

        relative_source_location = Utils::path_difference(@project_folder, File.dirname(source_file))
        fail "Source file #{source_file} must be within #{@project_folder}." if relative_source_location.nil?
        output_folder = File.join(@output_folder, relative_source_location)

        object_folders << output_folder unless object_folders.include?output_folder

        unless @tracked_folders.include?output_folder
          @tracked_folders << output_folder
          directory output_folder
          @parent_configuration.parent_project.add_files_to_clean(output_folder)
        end

        object_file = File.join(output_folder, source_file.pathmap('%n.o'))
        dependency_file = File.join(output_folder, source_file.pathmap('%n.d'))

        object_files << object_file
        @parent_configuration.parent_project.add_files_to_clean(object_file, dependency_file)

        file_type = get_file_type(source_file)

        mtfile object_file => [source_file] do |t|
          command_line = construct_compile_command(file_type, [source_file], get_include_paths, t.name)
          sh command_line
        end
        # Load dependencies if the dependencies file exists and the object file is not already scheduled to be rebuilt
        if File.file?(dependency_file) and not Rake::Task[object_file].needed?
          Rake::Task[object_file].force_needed() if not MTBuild::MakefileLoader.new.load(dependency_file)
        end
      end
      return object_files, object_folders
    end

    # Create Rake tasks for archival
    def create_static_library_tasks(objects, library_name)
      library_file = File.join(@output_folder, "lib#{library_name}#{@output_decorator}.a")
      library_folder = @output_folder

      unless @tracked_folders.include?library_folder
        @tracked_folders << library_folder
        directory library_folder
        @parent_configuration.parent_project.add_files_to_clean(library_folder)
      end

      @parent_configuration.parent_project.add_files_to_clean(library_file)

      file library_file => objects do |t|
        command_line = construct_archive_command(objects, t.name)
        sh command_line
      end
      return [library_file], [library_folder]
    end

    # Create Rake tasks for linking
    def create_application_tasks(objects, executable_name)
      elf_file = File.join(@output_folder, "#{executable_name}#{@output_decorator}")
      map_file = File.join(@output_folder, "#{executable_name}#{@output_decorator}.map")
      executable_folder = @output_folder

      unless @tracked_folders.include?executable_folder
        @tracked_folders << executable_folder
        directory executable_folder
        @parent_configuration.parent_project.add_files_to_clean(executable_folder)
      end

      @parent_configuration.parent_project.add_files_to_clean(map_file, elf_file)

      all_objects = objects+get_include_objects

      file elf_file => all_objects do |t|
        command_line = construct_link_command(all_objects, t.name, get_include_paths, get_library_paths, map_file)
        sh command_line
      end

      file map_file => elf_file

      return [elf_file], [map_file], [executable_folder]
    end

    private

    def get_file_type(source_file)
      file_extension = File.extname(source_file)
      return :cplusplus if ['.cc', '.cp', '.cxx', '.cpp', '.CPP', '.c++', '.C'].include? file_extension
      return :asm if ['.s', '.S', '.sx'].include? file_extension
      return :c
    end

    def construct_compile_command(file_type, prerequisites, include_paths, output_name)
      prerequisites_s = prerequisites.empty? ? '' : " \"#{prerequisites.join('" "')}\""
      include_paths_s = include_paths.empty? ? '' : " -I\"#{include_paths.join('" -I"')}\""
      cppflags_s = @cppflags.empty? ? '' : " #{@cppflags}"
      cflags_s = @cflags.empty? ? '' : " #{@cflags}"
      cxxflags_s = @cxxflags.empty? ? '' : " #{@cxxflags}"
      asflags_s = @asflags.empty? ? '' : " #{@asflags}"
      return "\"#{compiler_c}\"#{cppflags_s}#{cflags_s}#{prerequisites_s}#{include_paths_s} -MMD -c -o \"#{output_name}\"" if file_type == :c
      return "\"#{compiler_cpp}\"#{cppflags_s}#{cxxflags_s}#{prerequisites_s}#{include_paths_s} -MMD -c -o \"#{output_name}\"" if file_type == :cplusplus
      return "\"#{assembler}\"#{cppflags_s}#{asflags_s}#{prerequisites_s}#{include_paths_s} -MMD -c -o \"#{output_name}\"" if file_type == :asm
    end

    def construct_archive_command(prerequisites, output_name)
      prerequisites_s = prerequisites.empty? ? '' : " \"#{prerequisites.join('" "')}\""
      return "\"#{archiver}\" rcs \"#{output_name}\" #{prerequisites_s}"
    end

    def construct_link_command(prerequisites, output_name, include_paths, library_paths, map_name)
      prerequisites_s = prerequisites.empty? ? '' : " \"#{prerequisites.join('" "')}\""
      include_paths_s = include_paths.empty? ? '' : " -I\"#{include_paths.join('" -I"')}\""
      library_paths_s = library_paths.empty? ? '' : " -L\"#{library_paths.join('" -L"')}\""
      cppflags_s = @cppflags.empty? ? '' : " #{@cppflags}"
      cflags_s = @cflags.empty? ? '' : " #{@cflags}"
      cxxflags_s = @cxxflags.empty? ? '' : " #{@cxxflags}"
      ldflags_s = @ldflags.empty? ? '' : " #{@ldflags}"
      linker_script_s = if @linker_script.empty? then
                          ''
                        else
                          " -Wl,-T\"#{((Pathname.new @linker_script).relative?) ? File.join(@project_folder, @linker_script) : @linker_script}\""
                        end
      return "\"#{compiler_cpp}\"#{cppflags_s}#{cxxflags_s}#{ldflags_s}#{include_paths_s}#{library_paths_s}#{linker_script_s}#{prerequisites_s} #{map_flag(map_name)} -o \"#{output_name}\"" if @link_as_cpp
      return "\"#{compiler_c}\"#{cppflags_s}#{cflags_s}#{ldflags_s}#{include_paths_s}#{library_paths_s}#{linker_script_s}#{prerequisites_s} #{map_flag(map_name)} -o \"#{output_name}\""
    end

    def map_flag(map_file)
      return "-Wl,-map,\"#{map_file}\"" if @compiler_is_LLVM_gcc
      return "-Wl,-Map=\"#{map_file}\",--cref"
    end

    def assembler
      return 'gcc'
    end

    def compiler_c
      return 'gcc'
    end

    def compiler_cpp
      return 'g++'
    end

    def archiver
      return 'ar'
    end

    def linker_c
      return 'gcc'
    end

    def linker_cpp
      return 'g++'
    end

    include MTBuild::DSL

  end

end
