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

  end

end
