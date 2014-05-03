module MTBuild
  require 'mtbuild/toolchain'
  require 'mtbuild/utils'
  require 'rake/clean'
  require 'rake/loaders/makefile'

	class ToolchainGcc < Toolchain

    attr_accessor :cppflags, :cflags, :cxxflags, :asflags, :ldflags

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

        file object_file => [source_file] do |t|
          #puts "#{t.name}"
          #sh "#{compiler} -std=c99 -Dgcc -Wall -Werror -Wextra -pedantic-errors -ffunction-sections -fdata-sections -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb-interwork #{t.prerequisites.join(' ')} -I#{@include_paths.join(' -I')} -MMD -c -o #{t.name}"
          command_line = construct_compile_command(t.prerequisites, @include_paths, t.name)
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
        #puts "#{t.name}"
        sh "#{archiver} rcs #{t.name} #{t.prerequisites.join(' ')}"
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
        #puts "#{t.name}"
        #sh "#{compiler} -std=c99 -Dgcc -Wall -Werror -Wextra -pedantic-errors -ffunction-sections -fdata-sections -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb-interwork #{t.prerequisites.join(' ')} -I#{@include_paths.join(' -I')} -Wl,--entry,ResetISR -Wl,--gc-sections -Wl,-T#{linker_script} -o #{t.name}"
        command_line = construct_link_command(t.prerequisites, t.name)
        sh command_line
      end
      return [executable_file], [executable_folder]
    end

    private

    def construct_compile_command(prerequisites, include_paths, output_name)
      flags = build_flag_list(@cflags)
      return "#{compiler}#{flags} #{prerequisites.join(' ')} -I#{include_paths.join(' -I')} -MMD -c -o #{output_name}"
    end

    def construct_archive_command
    end

    def construct_link_command(prerequisites, output_name)
      flags = build_flag_list([@ldflags, @cflags, @cppflags, '-Wl,--gc-sections'])
      return "#{compiler}#{flags} #{prerequisites.join(' ')} -o #{output_name}"
    end

    def build_flag_list(flags)
      flags = [flags] unless flags.is_a? Array

      flag_list = ''
      flags.each do |f|
        if f.respond_to? :keys
          new_flag_list = build_flag_list_from_hash(f, flag_list)
          flag_list = "#{flag_list}#{new_flag_list}"
        else
          flag_list = "#{flag_list} #{f.to_s}" if f.to_s
        end
      end
      return flag_list
    end

    def build_flag_list_from_hash(flag_hash, previous_flag_list)
      flag_list = ''
      flag_hash.keys.each do |k|
        flag_string = get_flag(k.to_sym)
        if flag_string.nil?
          $stderr.puts "Warning: ignoring unknown flag '#{k}'"
        else
          flag_options = get_options_for_flag(k.to_sym)
          selected_option = flag_hash[k]
          if flag_options.respond_to? :call
            flag_option_string = flag_options.call(self, selected_option)
          else
            flag_option_string = flag_options[selected_option.to_sym]
            fail "Error: invalid option '#{selected_option}' for '#{flag_string}'. Valid options are: #{flag_options.keys.join(', ')}" if flag_option_string.nil?
          end
          flag = "#{flag_string}#{flag_option_string}"
          if flag
            $stderr.puts "Warning: duplicated option '#{flag}'" if flag_list.include? flag
            flag_list += " #{flag}"
          end
        end
      end
      return flag_list
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

    @gcc_flags = {
      linker_script: '-Wl,-T',
      entry: '-Wl,--entry,'
    }

    @gcc_options = {
      linker_script: lambda {|tc, o| File.join(tc.project_folder,o)},
      entry: lambda {|tc, o| o}
    }

    def self.gcc_flags
      return @gcc_flags
    end

    def self.gcc_options
      return @gcc_options
    end

    def get_flag(flagIdentifier)
      return ToolchainGcc.gcc_flags.fetch(flagIdentifier, nil)
    end

    def get_options_for_flag(flagIdentifier)
      return ToolchainGcc.gcc_options.fetch(flagIdentifier, nil)
    end

	end

  module DSL
    def gcc(configuration_hash)
      MTBuild::ToolchainGcc.new configuration_hash
    end
  end

end
