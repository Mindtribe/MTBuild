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

    # This hijacks the "--version" flag and displays the MTBuild version along
    # with the Rake version. All other options/flags are returned unmodified.
    def standard_rake_options
      return super.map do |opt|
        if opt.first == '--version'
          ['--version', '-V',
            "Display the program version.",
            lambda { |value|
              puts "mtbuild, version #{MTBuild::VERSION}"
              puts "rake, version #{RAKEVERSION}"
              exit
            }
          ]
        else
          opt
        end
      end
    end

  end

end