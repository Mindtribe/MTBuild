module MTBuild

	class Toolchain

    attr_accessor :output_folder

		def initialize(configuration_hash)
      @output_folder = ''
		end

    def create_compile_tasks(source_files)
      fail "Toolchain didn't provide create_compile_tasks"
    end

    def create_static_library_tasks(objects, library_name)
      fail "Toolchain didn't provide create_static_library_tasks"
    end

    include Rake::DSL
	end

end
