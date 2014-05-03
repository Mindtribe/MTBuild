module MTBuild

	class Toolchain

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
      add_include_objects(expand_project_relative_paths(configuration.fetch(:include_objects, [])))
      add_library_paths(expand_project_relative_paths(configuration.fetch(:library_paths, [])))
		end

    def add_include_objects(*include_objects)
      include_objects.each do |include_object|
        if include_object.respond_to? :to_ary
          add_include_objects(*include_object.to_ary)
        else
          @include_objects << include_object unless @include_objects.include?include_object
        end
      end
    end

    def add_include_paths(*include_paths)
      include_paths.each do |include_path|
        if include_path.respond_to? :to_ary
          add_include_paths(*include_path.to_ary)
        else
          @include_paths << include_path unless @include_paths.include?include_paths
        end
      end
    end

    def add_library_paths(*library_paths)
      library_paths.each do |library_path|
        if library_path.respond_to? :to_ary
          add_library_paths(*library_path.to_ary)
        else
          @library_paths << library_path unless @library_paths.include?library_path
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

    def create_application_tasks(objects, executable_name)
      fail "Toolchain didn't provide create_executable_tasks"
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

    include Rake::DSL
	end

end
