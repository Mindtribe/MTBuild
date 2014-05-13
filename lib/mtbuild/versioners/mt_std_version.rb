module MTBuild
  require 'mtbuild/versioner'

  Versioner.register_versioner(:mt_std_version, 'MTBuild::VersionerMTStdVersion')

  class VersionerMTStdVersion < Versioner

    def initialize(project_name, project_folder, output_folder, configuration_name, configuration)
      super
      @version_files = Utils.expand_file_list(configuration.fetch(:files, []), [], @project_folder)
    end

    def create_version_tasks
      namespace @configuration_name do
        @version_files.each do |file|
          desc "Update version for '#{@project_name}' with configuration '#{@configuration_name}'"
          version_task = task :Version => file do |t, args|
            update_version(file, major, minor, revision, build, version_string, git_SHA)
            args.with_defaults(:major => nil, :minor => nil)
          end
        end
      end
    end

    private

    def check_configuration(configuration)
      super
      fail "No version files specified for #{@project_name}:#{@configuration_name}" if configuration.fetch(:files, nil).nil?
    end

    # This function searches through a C file for version definitions of roughly the following format:
    #
    # #define xxxMAJOR            0
    # #define xxxMINOR            0
    # #define xxxREVISION         0
    # #define xxxBUILD            0
    # #define xxxVERSIONSTRING    "0"
    # #define xxxGITSHA           "0000000000000000000000000000000000000000"
    #
    # The "xxx" can include almost any valid C/C++ identifier text as needed for the particular application. The spacing
    # between the identifier and the defined value is flexible. The order of the definitions is not important and
    # definitions can be repeated or omitted. For more detail on the exact search criteria, review the regular expressions
    # below.
    #
    # When one of the above lines is found, the defined value is replaced by the respective value passed into this
    # function.
    def update_version(file_name, major=0, minor=0, revision=0, build=0, version_string="0", git_SHA="0000000000000000000000000000000000000000")
      matching_list = [
        [/(\s*#define\s.+?MAJOR\s*)(\S+?)(\s*.*$)/,           "\\1#{major}\\3"],
        [/(\s*#define\s.+?MINOR\s*)(.+?)(\s*$)/,              "\\1#{minor}\\3"],
        [/(\s*#define\s.+?REVISION\s*)(.+?)(\s*$)/,           "\\1#{revision}\\3"],
        [/(\s*#define\s.+?BUILD\s*)(.+?)(\s*$)/,              "\\1#{build}\\3"],
        [/(\s*#define\s.+?VERSIONSTRING\s*\")(.+?)(\"\s*$)/,  "\\1#{version_string}\\3"],
        [/(\s*#define\s.+?GITSHA\s*\")(.+?)(\"\s*$)/,         "\\1#{git_SHA}\\3"]
      ]

      File.open(file_name) do |file|
        file.lines.each do |line|
          line = replace_matching_text(matching_list, line)
          puts line
        end
      end
    end

    def replace_matching_text(matching_list, line)
      matching_list.each do |matching_expression, replacement_text|
        line = line.sub(matching_expression, replacement_text)
      end
      return line
    end

  end

end
