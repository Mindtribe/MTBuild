module MTBuild
  require 'mtbuild/toolchains/gcc'

  Toolchain.register_toolchain(:arm_none_eabi_gcc, 'MTBuild::ToolchainArmNoneEabiGcc')

	class ToolchainArmNoneEabiGcc < ToolchainGcc

		def initialize(configuration)
      super
		end

    def create_application_tasks(objects, executable_name)
      elf_file = File.join(@output_folder, "#{executable_name}#{@binary_decorator}.elf")
      bin_file = File.join(@output_folder, "#{executable_name}#{@binary_decorator}.bin")
      hex_file = File.join(@output_folder, "#{executable_name}#{@binary_decorator}.hex")
      map_file = File.join(@output_folder, "#{executable_name}#{@binary_decorator}.map")
      executable_folder = @output_folder
      directory executable_folder
      CLOBBER.include(executable_folder)
      CLOBBER.include(elf_file)

      all_objects = objects+get_include_objects

      file elf_file => all_objects do |t|
        command_line = construct_link_command(all_objects, t.name, get_include_paths, get_library_paths, map_file)
        sh command_line
      end

      file map_file => elf_file

      file bin_file => elf_file do |t|
        command_line = construct_objcopy_command(elf_file, t.name, ' -Obinary')
        sh command_line
      end
      file hex_file => elf_file do |t|
        command_line = construct_objcopy_command(elf_file, t.name, ' -Oihex')
        sh command_line
      end

      return [elf_file, bin_file, hex_file], [map_file], [executable_folder]
    end

    private

    def construct_objcopy_command(input_name, output_name, objcopyflags)
      return "#{objcopy}#{objcopyflags} #{input_name} #{output_name}"
    end

    def compiler
      return 'arm-none-eabi-gcc'
    end

    def archiver
      return 'arm-none-eabi-ar'
    end

    def linker
      return 'arm-none-eabi-gcc'
    end

    def objcopy
      return 'arm-none-eabi-objcopy'
    end

	end

end
