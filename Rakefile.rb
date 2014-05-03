libFolder = File.join(File.dirname(__FILE__),'lib')
$:.unshift(File.expand_path(libFolder)) unless $:.include?(File.expand_path(libFolder)) || $:.include?(libFolder)

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
