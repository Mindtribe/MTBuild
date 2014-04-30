module MTBuild

	class Toolchain

    require 'set'

    attr_accessor :output_folder
    attr_accessor :project_folder
    attr_reader :include_objects
    attr_reader :include_paths
    attr_reader :library_paths

		def initialize(configuration)
      @output_folder = ''
      @project_folder = ''
      @include_objects = []
      @include_paths = []
      @library_paths = []

      add_include_paths(expand_project_relative_paths(configuration.fetch(:include_paths, [])))
      add_include_objects(expand_project_relative_paths(configuration.fetch(:include_paths, [])))
      add_library_paths(expand_project_relative_paths(configuration.fetch(:library_paths, [])))
		end

    def add_include_objects(*include_objects)
      include_objects.each do |include_object|
        if include_object.respond_to? :to_ary
          add_include_objects(*include_object.to_ary)
        else
          @include_objects << include_object if !include_objects.include?include_object
        end
      end
    end

    def add_include_paths(*include_paths)
      include_paths.each do |include_path|
        if include_path.respond_to? :to_ary
          add_include_paths(*include_path.to_ary)
        else
          @include_paths << include_path if !include_paths.include?include_paths
        end
      end
    end

    def add_library_paths(*library_paths)
      library_paths.each do |library_path|
        if library_path.respond_to? :to_ary
          add_library_paths(*library_path.to_ary)
        else
          @library_paths << library_path if !library_paths.include?library_path
        end
      end
    end

    def expand_project_relative_paths(*paths)
      expanded_paths = []
      paths.each do |path|
        if path.respond_to? :to_ary
          expanded_paths += expand_project_relative_paths(*path.to_ary)
        else
          expanded_paths << File.expand_path(File.join(@project_folder, path))
        end
      end
      return expanded_paths
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
