module MTBuild

  @default_output_folder = 'build'

  # This returns the default name that MTBuild uses for the build output folder
  def self.default_output_folder
    return @default_output_folder
  end

end
