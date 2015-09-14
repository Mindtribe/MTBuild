module Rake
  class << self
    # Singleton MTBuild application instance
    def application
      @application ||= MTBuild::Application.new
    end
  end
end

module MTBuild

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

    def run
      standard_exception_handling do
        init
        load_rakefile
        create_default_task_if_none_exists
        top_level
      end
    end

    # Override init to pass mtbuild as the app name
    def init(app_name='mtbuild')
      super
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
      # This adds MTBuild-specific options
      options |= [
          ['--super-dry-run',
           "Do a dry run printing actions, but not executing them.",
           lambda { |value|
             Rake.verbose(true)
             Rake.nowrite(true)
           }
          ],
      ]
      sort_options(options)
    end

    def create_default_task_if_none_exists
      if lookup(default_task_name).nil?
        task default_task_name do
          puts 'Nothing to do because no projects specified default tasks.'
          puts 'Use the -T flag to see the list of tasks you can build.'
        end
      end
    end

    def default_task_name
      'all'
    end

    include Rake::DSL
  end

end