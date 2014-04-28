require 'rake/clean'

local_lib_folder = File.join(File.dirname(__FILE__),"MTBuild")
$:.unshift(File.expand_path(local_lib_folder)) unless $:.include?(local_lib_folder) || $:.include?(File.expand_path(local_lib_folder))
require 'MTBuild'

current_folder = File.dirname(__FILE__)

require_relative 'MyLibrary/Rakefile'
require_relative 'MyApps/Rakefile'

task :all do
  puts 'Done!'
end

task :default => :all
