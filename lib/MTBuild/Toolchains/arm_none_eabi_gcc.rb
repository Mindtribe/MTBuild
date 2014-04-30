module MTBuild
  require 'MTBuild/Toolchain'
  require 'rake/clean'

	class ToolchainArmNoneEabiGcc < Toolchain

    attr_accessor :cpu, :linker_script

		def initialize(configuration)
      super
		end

    def create_compile_tasks(source_files)
      object_files = []

      source_files.each do |source_file|

        relative_source_location = Utils::path_difference(@project_folder, File.dirname(source_file))
        fail "Source file #{source_file} must be within #{@project_folder}." if relative_source_location.nil?
        output_folder = File.join(@output_folder, relative_source_location)

        object_file = File.join(output_folder, source_file.pathmap('%n.o'))
        dependency_file = File.join(output_folder, source_file.pathmap('%n.d'))

        object_files << object_file
        CLEAN.include(object_file)
        CLEAN.include(dependency_file)
        file object_file => [source_file] do |t|
          puts "#{t.name}"
          #sh "~/MTTools/OSX/bin/arm-none-eabi-gcc #{t.prerequisites.join(' ')} -I#{includeFolders.join(' -I')} -MMD -c -o #{t.name}"
        end
        Rake::MakefileLoader.new.load(dependency_file) if File.file?(dependency_file)
      end
      return object_files
    end

    def create_static_library_tasks(objects, library_name)
      library_file = File.join(@output_folder, "lib#{library_name}.a")
      CLEAN.include(library_file)

      file library_file => objects do |t|
        puts "#{t.name}"
        #sh "~/MTTools/OSX/bin/arm-none-eabi-gcc #{t.prerequisites.join(' ')} -I#{includeFolders.join(' -I')} -MMD -c -o #{t.name}"
      end
      return library_file
    end

    def create_executable_tasks(objects, executable_name)
      executable_file = File.join(@output_folder, "#{executable_name}")
      CLEAN.include(executable_file)

      file executable_file => objects do |t|
        puts "#{t.name}"
        #sh "~/MTTools/OSX/bin/arm-none-eabi-gcc #{t.prerequisites.join(' ')} -I#{includeFolders.join(' -I')} -MMD -c -o #{t.name}"
      end
      return executable_file
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
