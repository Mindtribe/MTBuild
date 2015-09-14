module MTBuild

  module Utils

    require 'pathname'

    def self.path_difference(root, subdir)
      root_path = Pathname.new(root)
      subdir_path = Pathname.new(subdir)
      difference_path = subdir_path.relative_path_from(root_path)
      difference = difference_path.to_path
      return nil if difference.include? '..'
      return '' if difference.eql? '.'
      return difference
    end

    def self.expand_file_list(included_files, excluded_files, base_folder=nil)
      file_list = FileList.new()

      included_files = Utils.ensure_array(included_files).flatten.collect{|s| base_folder ? File.join(base_folder, s) : s}
      file_list.include(included_files)

      excluded_files = Utils.ensure_array(excluded_files).flatten.collect{|e| base_folder ? File.join(base_folder, e) : e}
      file_list.exclude(*excluded_files)

      return file_list.to_ary.collect{|f| File.expand_path(f)}
    end

    def self.expand_folder_list(included_folders, base_folder=nil)
      included_folders = Utils.ensure_array(included_folders).flatten.collect{|f| base_folder ? File.join(base_folder, f) : f}
      return Dir.glob(included_folders).to_ary.reject{|f| !File.directory?f}.collect{|f| File.expand_path(f)}
    end

    def self.ensure_array(input)
      input = [input] unless input.respond_to?(:to_ary)
      return input
    end

    def self.merge_configurations(default, override)
      return default.merge(override) { |key, old_value, new_value|
        if old_value.is_a? Hash and new_value.is_a? Hash then merge_configurations(old_value, new_value)
        elsif old_value.is_a? Array and new_value.is_a? Array then old_value | new_value
        else new_value end }
    end

  end

end
