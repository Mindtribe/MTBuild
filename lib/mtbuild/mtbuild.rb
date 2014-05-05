module MTBuild

  def self.set_build_folder(folder)
    @build_folder ||= folder
  end

  def self.build_folder
    return @build_folder || File.join(Rake.original_dir, 'build')
  end

end
