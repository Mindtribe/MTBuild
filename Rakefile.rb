libFolder = File.join(File.dirname(__FILE__),'lib')
$:.unshift(File.expand_path(libFolder)) unless $:.include?(File.expand_path(libFolder)) || $:.include?(libFolder)

require 'rspec/core/rake_task'
require 'rubygems/package_task'
require 'rdoc/task'

# Task to run RSpec tests
RSpec::Core::RakeTask.new(:spec)

# Task to package gem
gemspec = Gem::Specification.load('mtbuild.gemspec')
Gem::PackageTask.new(gemspec) do |pkg|
end

# Task to create docs
RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_files.include(gemspec.files)
end

# Package only if tests pass and documentation generated
Rake::Task[:package].prerequisites.insert(0, :spec)
Rake::Task[:package].prerequisites.insert(1, :rdoc)

# Task to install gem
desc "Install the gem file #{gemspec.file_name}"
task :install => [:package] do
  sh "gem install pkg/#{gemspec.file_name}"
end

# Package by default
task :default => [:package]
