module Rake
  class << self
    def application
      @application ||= MTBuild::Application.new
    end
  end
end

module MTBuild

  require 'rake'

  class Application < Rake::Application

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