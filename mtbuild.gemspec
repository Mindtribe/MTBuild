# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mtbuild/version'

Gem::Specification.new do |spec|
  spec.name          = "mtbuild"
  spec.version       = MTBuild::VERSION
  spec.authors       = ["Jerry Ryle"]
  spec.email         = ["info@mindtribe.com"]
  spec.summary       = %q{rake-based build system for C/C++ projects}
  spec.description   = %q{mtbuild is a rake-based build system for C/C++ projects. It provides a DSL for declaring workspaces and projects, which generate rake tasks.}
  spec.homepage      = "https://github.com/MindTribe/MTBuild"
  spec.license       = "BSD-3-Clause"

  spec.files         = [Dir.glob('{bin,lib}/**/*'), 'LICENSE.md', 'README.md']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rake', '~> 0.9', '>= 0.9.6'

  spec.add_development_dependency "rake", '~> 0.9', '>= 0.9.6'
end
