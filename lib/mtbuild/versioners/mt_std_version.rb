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
        desc "Update version for '#{@project_name}' with configuration '#{@configuration_name}'"
        @version_files.each do |file|
          version_task = task :Version, [:major, :minor, :revision, :build, :version_string, :git_SHA] => file do |t, args|
            args.with_defaults(:major => '', :minor => '', :revision => '', :build => '', :version_string => '', :git_SHA => '')
            update_version(file, args.major, args.minor, args.revision, args.build, args.version_string, args.git_SHA)
            puts "updated version in '#{file}'"
          end
        end
      end
    end

    private

    def check_configuration(configuration)
      super
      fail "No version files specified for #{@project_name}:#{@configuration_name}" if configuration.fetch(:files, nil).nil?
    end

    # This function searches through a file for version definitions of roughly the following format:
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
    # When one or more of the above lines is found, the defined value is replaced by the respective value passed into this
    # function.
    def update_version(file_name, major=nil, minor=nil, revision=nil, build=nil, version_string=nil, git_SHA=nil)
      matching_list = []

      matching_list << [/(\s*#define\s.+?MAJOR\s*)(\S+?)(\s*.*$)/,          "\\1#{major}\\3"] unless major.empty?
      matching_list << [/(\s*#define\s.+?MINOR\s*)(.+?)(\s*$)/,             "\\1#{minor}\\3"] unless minor.empty?
      matching_list << [/(\s*#define\s.+?REVISION\s*)(.+?)(\s*$)/,          "\\1#{revision}\\3"] unless revision.empty?
      matching_list << [/(\s*#define\s.+?BUILD\s*)(.+?)(\s*$)/,             "\\1#{build}\\3"] unless build.empty?
      matching_list << [/(\s*#define\s.+?VERSIONSTRING\s*\")(.+?)(\"\s*$)/, "\\1#{version_string}\\3"] unless version_string.empty?
      matching_list << [/(\s*#define\s.+?GITSHA\s*\")(.+?)(\"\s*$)/,        "\\1#{git_SHA}\\3"] unless git_SHA.empty?

      fail "Nothing to do. Please specify at least one version component to update." if matching_list.empty?

      file_contents = File.read(file_name)
      matching_list.each do |matching_expression, replacement_text|
        file_contents = file_contents.gsub(matching_expression, replacement_text)
      end
      File.open(file_name, "w") {|file| file.puts file_contents}
    end

  end

end
