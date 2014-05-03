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
        #sh "#{archiver} rcs #{t.name} #{t.prerequisites.join(' ')}"
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

    def construct_archive_command(prerequisites, output_name)
      return "#{archiver} rcs #{output_name} #{prerequisites.join(' ')}"
    end

    def construct_link_command(prerequisites, output_name)
      flags = build_flag_list([@ldflags, @cflags, @cppflags, '-Wl,--gc-sections'])
      return "#{compiler}#{flags} #{prerequisites.join(' ')} -o #{output_name}"
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

    @gcc_standards = {
      c90: 'c90',
      c89: 'c89',
      iso9899_1990: 'iso9899:1990',
      iso9899_199409: 'iso9899:199409',
      c99: 'c99',
      c9x: 'c9x',
      iso9899_1999: 'iso9899:1999',
      iso9899_199x: 'iso9899:199x',
      c11: 'c11',
      c1x: 'c1x',
      iso9899_2011: 'iso9899:2011',
      gnu90: 'gnu90',
      gnu89: 'gnu89',
      gnu99: 'gnu99',
      gnu9x: 'gnu9x',
      gnu11: 'gnu11',
      gnu1x: 'gnu1x',
      cpp98: 'c++98',
      cpp03: 'c++03',
      gnupp98: 'gnu++98',
      gnupp03: 'gnu++03',
      cpp11: 'c++11',
      cpp0x: 'c++0x',
      gnupp11: 'gnu++11',
      gnupp0x: 'gnu++0x',
      cpp1y: 'c++1y',
      gnupp1y: 'gnu++1y'
    }

    @gcc_flags = {
      #overall compile options
      pipe: '',
      #c dialect compile options
      ansi: '',
      std: '',
      gnu89_inline: '',
      allow_parameterless_variadic_functions: '',
      no_asm: '',
      no_builtin: '',
      no_builtins: '',
      hosted: '',

      #link options
      linker_script: '-Wl,-T',
      entry: '-Wl,--entry,',
      libraries: '',
      objc: '',
      startfiles: '',
      defaultlibs: '',
      stdlib: '',
      pie: '',
      rdynamic: '',
      static: '',
      shared: '',
      libgcc: '',
      libasan: '',
      libtsan: '',
      liblsan: '',
      libubsan: '',
      libstdcplusplus: '',
      symbolic: ''
    }

    @gcc_options = {
      #overall compile options
      pipe: { yes:'-pipe', no:''},
      #c dialect compile options
      ansi: { yes:'-ansi', no:''},
      std: @gcc_standards,
      gnu89_inline: { yes:'-fgnu89-inline', no:''},
      allow_parameterless_variadic_functions: { yes:'-fallow-parameterless-variadic-functions', no:''},
      no_asm: { yes:'-fno-asm', no:''},
      no_builtin: { yes:'-fno-builtin', no:''},
      no_builtins: lambda { |tc, o| "-fno-builtin-#{[o].flatten.join(' -fno-builtin-')}" },
      hosted: { yes:'-fhosted', no:''},


      #link options
      linker_script: lambda { |tc, o| File.join(tc.project_folder,o) },
      entry: lambda { |tc, o| o },
      libraries: lambda { |tc, o| "-l#{[o].flatten.join(' -l')}" },
      objc: { yes:'-lobjc', no:''},
      startfiles: { yes:'', no:'-nostartfiles' },
      defaultlibs: { yes:'', no:'-nodefaultlibs' },
      stdlib: { yes:'', no:'-nostdlib' },
      pie: { yes:'-pie', no:'' },
      rdynamic: { yes:'-rdynamic', no:'' },
      static: { yes:'-static', no:'' },
      shared: { yes:'-shared', no:'' },
      libgcc: { shared:'-shared-libgcc', static:'-static-libgcc' },
      libasan: { shared: '', static:'-static-libasan' },
      libtsan: { shared: '', static:'-static-libtsan' },
      liblsan: { shared: '', static:'-static-liblsan' },
      libubsan: { shared: '', static:'-static-libubsan' },
      libstdcplusplus: { shared: '', static:'-static-libstdc++' },
      symbolic: { yes:'-symbolic', no:'' },
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
