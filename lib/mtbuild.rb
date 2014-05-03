require 'rake'

require "mtbuild/application_project"
require "mtbuild/application_task"
require "mtbuild/dsl"
require "mtbuild/mtbuild"
require "mtbuild/staticlibrary_project"
require "mtbuild/staticlibrary_task"
require "mtbuild/version"
require "mtbuild/workspace"

# Load toolchains
require 'mtbuild/toolchains/gcc.rb'
require 'mtbuild/toolchains/arm_none_eabi_gcc.rb'
