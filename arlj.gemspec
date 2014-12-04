# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arlj/version'

Gem::Specification.new do |spec|
  spec.name          = 'arlj'
  spec.version       = Arlj::VERSION
  spec.authors       = ['Benjamin Feng']
  spec.email         = ['contact@fengb.info']
  spec.summary       = %q{ActiveRecord Left Join}
  spec.description   = %q{Make left joins feel like first-class citizens in ActiveRecord.}
  spec.homepage      = 'https://github.com/fengb/arlj'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activerecord', '>= 3.1'
  spec.add_runtime_dependency 'memoist',      '~> 0.11.0'

  spec.add_development_dependency 'bundler',  '~> 1.7'
  spec.add_development_dependency 'rake',     '~> 10.0'
  spec.add_development_dependency 'rspec',    '~> 3.0'
  spec.add_development_dependency 'temping',  '~> 3.2'
end
