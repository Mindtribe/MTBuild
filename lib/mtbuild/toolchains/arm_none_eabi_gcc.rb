module MTBuild
  require 'mtbuild/toolchain'
  require 'mtbuild/utils'
  require 'rake/clean'
  require 'rake/loaders/makefile'

	class ToolchainArmNoneEabiGcc < Toolchain

    attr_accessor :cpu, :linker_script

		def initialize(configuration)
      super

      begin
        toolchain_test_output=%x[arm-none-eabi-gcc --version] ; toolchain_test_passed=$?.success?
      rescue
        toolchain_test_passed = false
      end
      fail "Toolchain component arm-none-eabi-gcc not found." unless toolchain_test_passed

      @cpu = configuration.fetch(:cpu, nil)
      @linker_script = configuration.fetch(:linker_script, nil)
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
          sh "arm-none-eabi-gcc -std=c99 -Dgcc -Wall -Werror -Wextra -pedantic-errors -ffunction-sections -fdata-sections -mcpu=#{@cpu} -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb-interwork #{t.prerequisites.join(' ')} -I#{@include_paths.join(' -I')} -MMD -c -o #{t.name}"
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
        sh "arm-none-eabi-ar rcs #{t.name} #{t.prerequisites.join(' ')}"
      end
      return [library_file], [library_folder]
    end

    def create_application_tasks(objects, executable_name)
      executable_file = File.join(@output_folder, "#{executable_name}")
      executable_folder = @output_folder
      directory executable_folder
      CLOBBER.include(executable_folder)
      CLOBBER.include(executable_file)

      linker_script = File.join(@project_folder,@linker_script)

      file executable_file => objects+@include_objects do |t|
        #puts "#{t.name}"
          sh "arm-none-eabi-gcc -std=c99 -Dgcc -Wall -Werror -Wextra -pedantic-errors -ffunction-sections -fdata-sections -mcpu=#{@cpu} -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb-interwork #{t.prerequisites.join(' ')} -I#{@include_paths.join(' -I')} -Wl,--entry,ResetISR -Wl,--gc-sections -Wl,-T#{linker_script} -o #{t.name}"
      end
      return [executable_file], [executable_folder]
    end

    def library_name_for_project(project_name)
      return "lib#{project_name}.a"
    end

	end

  module DSL
    def arm_none_eabi_gcc(configuration_hash)
      MTBuild::ToolchainArmNoneEabiGcc.new configuration_hash
    end
  end

end
