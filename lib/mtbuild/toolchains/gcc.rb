module MTBuild
  require 'mtbuild/toolchain'
  require 'mtbuild/utils'
  require 'rake/clean'
  require 'rake/loaders/makefile'

	class ToolchainGcc < Toolchain

    attr_accessor :cppflags, :cflags, :cxxflags, :asflags, :ldflags, :linker_script

		def initialize(configuration)
      super

      begin
        toolchain_test_output=%x[#{compiler} --version] ; toolchain_test_passed=$?.success?
      rescue
        toolchain_test_passed = false
      end
      fail "Toolchain component #{compiler} not found." unless toolchain_test_passed

      @cppflags = configuration.fetch(:cppflags, '')
      @cflags = configuration.fetch(:cflags, '')
      @cxxflags = configuration.fetch(:cxxflags, '')
      @asflags = configuration.fetch(:asflags, '')
      @ldflags = configuration.fetch(:ldflags, '')
      @linker_script = configuration.fetch(:linker_script, '')
		end

    def create_compile_tasks(source_files)
      object_files = []
      object_folders = []

      source_files.each do |source_file|

        relative_source_location = Utils::path_difference(@project_folder, File.dirname(source_file))
        fail "Source file #{source_file} must be within #{@project_folder}." if relative_source_location.nil?
        output_folder = File.join(@output_folder, relative_source_location)

        object_folders << output_folder unless object_folders.include?output_folder

        directory output_folder
        CLOBBER.include(output_folder)

        object_file = File.join(output_folder, source_file.pathmap('%n.o'))
        dependency_file = File.join(output_folder, source_file.pathmap('%n.d'))

        object_files << object_file
        CLEAN.include(object_file)
        CLEAN.include(dependency_file)

        file_type = get_file_type(source_file)

        file object_file => [source_file] do |t|
          command_line = construct_compile_command(file_type, t.prerequisites, @include_paths, t.name)
          sh command_line
        end
        Rake::MakefileLoader.new.load(dependency_file) if File.file?(dependency_file)
      end
      return object_files, object_folders
    end

    def create_static_library_tasks(objects, library_name)
      library_file = File.join(@output_folder, "lib#{library_name}.a")
      library_folder = @output_folder
      directory library_folder
      CLOBBER.include(library_folder)
      CLOBBER.include(library_file)

      file library_file => objects do |t|
        command_line = construct_archive_command(t.prerequisites, t.name)
        sh command_line
      end
      return [library_file], [library_folder]
    end

    def create_application_tasks(objects, executable_name)
      executable_file = File.join(@output_folder, "#{executable_name}")
      executable_folder = @output_folder
      directory executable_folder
      CLOBBER.include(executable_folder)
      CLOBBER.include(executable_file)

      file executable_file => objects+@include_objects do |t|
        command_line = construct_link_command(t.prerequisites, t.name)
        sh command_line
      end
      return [executable_file], [executable_folder]
    end

    private

    def get_file_type(source_file)
      file_extension = File.extname(source_file)
      return :cplusplus if ['.cc', '.cp', '.cxx', '.cpp', '.CPP', '.c++', '.C'].include? file_extension
      return :asm if ['.s', '.S', '.sx'].include? file_extension
      return :c
    end

    def construct_compile_command(file_type, prerequisites, include_paths, output_name)
      prerequisites_s = prerequisites.empty? ? '' : " #{prerequisites.join(' ')}"
      include_paths_s = include_paths.empty? ? '' : " -I#{include_paths.join(' -I')}"
      cppflags_s = @cppflags.empty? ? '' : " #{@cppflags}"
      cflags_s = @cflags.empty? ? '' : " #{@cflags}"
      return "#{compiler}#{cppflags_s}#{cflags_s}#{prerequisites_s}#{include_paths_s} -MMD -c -o #{output_name}" if file_type == :c
      return "#{compiler}#{cppflags_s}#{cxxflags_s}#{prerequisites_s}#{include_paths_s} -MMD -c -o #{output_name}" if file_type == :cplusplus
      return "#{compiler}#{cppflags_s}#{asflags_s}#{prerequisites_s}#{include_paths_s} -MMD -c -o #{output_name}" if file_type == :asm
    end

    def construct_archive_command(prerequisites, output_name)
      prerequisites_s = prerequisites.empty? ? '' : " #{prerequisites.join(' ')}"
      return "#{archiver} rcs #{output_name} #{prerequisites_s}"
    end

    def construct_link_command(prerequisites, output_name)
      prerequisites_s = prerequisites.empty? ? '' : " #{prerequisites.join(' ')}"
      cppflags_s = @cppflags.empty? ? '' : " #{@cppflags}"
      cflags_s = @cflags.empty? ? '' : " #{@cflags}"
      ldflags_s = @ldflags.empty? ? '' : " #{@ldflags}"
      linker_script_s = @linker_script.empty? ? '' : " -Wl,-T#{File.join(@project_folder,@linker_script)}"
      return "#{compiler}#{cppflags_s}#{cflags_s}#{ldflags_s}#{linker_script_s}#{prerequisites_s} -o #{output_name}"
    end

    def compiler
      return 'gcc'
    end

    def archiver
      return 'ar'
    end

    def linker
      return 'gcc'
    end

	end

  module DSL
    def gcc(configuration_hash)
      MTBuild::ToolchainGcc.new configuration_hash
    end
  end

end
