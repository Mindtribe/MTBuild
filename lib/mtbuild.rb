module MTBuild
  # The current MTBuild version.
  VERSION = '0.1.5'
end

require 'rake'
require 'mtbuild/application'
require 'mtbuild/application_project'
require 'mtbuild/application_task'
require 'mtbuild/dsl'
require 'mtbuild/framework_project'
require 'mtbuild/framework_task'
require 'mtbuild/mtbuild'
require 'mtbuild/mtfile_task'
require 'mtbuild/staticlibrary_project'
require 'mtbuild/staticlibrary_task'
require 'mtbuild/test_application_project'
require 'mtbuild/test_application_task'
require 'mtbuild/version'
require 'mtbuild/workspace'
