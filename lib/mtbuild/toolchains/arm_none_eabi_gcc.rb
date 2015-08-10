module MTBuild
  require 'mtbuild/toolchains/gcc'

  Toolchain.register_toolchain(:arm_none_eabi_gcc, 'MTBuild::ToolchainArmNoneEabiGcc')

  # This ToolchainGcc subclass can build using arm-non-eabi-gcc
  class ToolchainArmNoneEabiGcc < ToolchainGcc

    def initialize(parent_configuration, toolchain_configuration)
      super
    end

    # Create Rake tasks for linking
    def create_application_tasks(objects, executable_name)
      elf_file = File.join(@output_folder, "#{executable_name}#{@output_decorator}.elf")
      bin_file = File.join(@output_folder, "#{executable_name}#{@output_decorator}.bin")
      hex_file = File.join(@output_folder, "#{executable_name}#{@output_decorator}.hex")
      map_file = File.join(@output_folder, "#{executable_name}#{@output_decorator}.map")
      executable_folder = @output_folder

      unless @tracked_folders.include?executable_folder
        @tracked_folders << executable_folder
        directory executable_folder
        @parent_configuration.parent_project.add_files_to_clean(executable_folder)
      end

      @parent_configuration.parent_project.add_files_to_clean(elf_file, bin_file, hex_file, map_file)

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
      return "\"#{objcopy}\"#{objcopyflags} \"#{input_name}\" \"#{output_name}\""
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
