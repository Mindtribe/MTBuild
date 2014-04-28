local_lib_folder = File.join(File.dirname(__FILE__),"MTBuild")
$:.unshift(File.expand_path(local_lib_folder)) unless $:.include?(local_lib_folder) || $:.include?(File.expand_path(local_lib_folder))
require 'MTBuild'

workspace :MTBuildTest do |w|
  w.add_project('MyLibrary')
  w.add_project('MyApps')
end
