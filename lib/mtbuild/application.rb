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

  # This subclasses the Rake::Application class only only to inject the MTBuild
  # version number for display when mtbuild is invoked with the --version flag.
  class Application < Rake::Application

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