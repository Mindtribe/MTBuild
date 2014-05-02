module MTBuild

  require 'logger'

  def self.logger
    @logger
  end

  def self.set_build_folder(folder)
    @build_folder ||= folder
  end

  def self.build_folder
    return @build_folder || File.join(Rake.original_dir, 'build')
  end

  @logger = Logger.new(STDERR)
  @logger.level = Logger::WARN
  @logger.formatter = proc do |severity, datetime, progname, msg|
    severity = {'WARN'=>'Warning', 'FATAL'=>'Fatal Error', 'ERROR'=>'Error', 'INFO'=>'Info', 'DEBUG'=>'Debug'}[severity]
    "#{severity}: #{msg}\n"
  end

end
