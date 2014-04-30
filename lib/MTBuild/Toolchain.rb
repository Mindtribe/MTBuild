module MTBuild

	class Toolchain

    require 'set'

    attr_accessor :output_folder, :include_paths, :library_paths

		def initialize(configuration_hash)
      @output_folder = ''
      @include_paths = Set.new()
      @library_paths = Set.new()
		end

    def add_include_paths(*include_paths)
      include_paths.each do |include_path|
        if include_path.respond_to? :to_ary
          add_include_paths(*include_path.to_ary)
        else
          include_path = File.expand_path(File.Join(output_folder,include_path))
          @include_paths << include_path
        end
      end
    end

    def add_library_paths(*library_paths)
      library_paths.each do |library_path|
        if library_path.respond_to? :to_ary
          add_library_paths(*library_path.to_ary)
        else
          library_path = File.expand_path(File.Join(output_folder,include_path))
          @library_paths << library_path
        end
      end
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
