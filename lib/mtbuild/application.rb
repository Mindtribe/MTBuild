module Rake
  class << self
    # Singleton MTBuild application instance
    def application
      @application ||= MTBuild::Application.new
    end
  end
end

module MTBuild

  require 'rake'

  # This subclasses the Rake::Application class to override default Rake
  # behaviors with MTBuild-specific behaviors
  class Application < Rake::Application

    # List of rakefile names to look for
    attr_reader :rakefiles

    # Default list of mtbuildfile names
    DEFAULT_RAKEFILES = [
      'mtbuildfile',
      'MTBuildfile',
      'mtbuildfile.rb',
      'MTBuildfile.rb'
    ].freeze

    # This overrides the default rakefile names with the mtbuildfile names
    def initialize
      super
      @rakefiles = DEFAULT_RAKEFILES.dup
    end

    # This modifies Rake's command line options to do MTBuild-specific things
    def standard_rake_options
      # This hijacks the "--version" flag and displays the MTBuild version along
      # with the Rake version.
      options = super.map do |opt|
        if opt.first == '--version'
          ['--version', '-V',
            "Display the program version.",
            lambda { |value|
              puts "mtbuild, version #{MTBuild::VERSION}"
              puts "rake, version #{Rake::VERSION}"
              exit
            }
          ]
        else
          opt
        end
      end
      # This adds MTBuild-specific options (For future development)
      # options |= [
      # ]
      # sort_options(options)
    end

  end

end