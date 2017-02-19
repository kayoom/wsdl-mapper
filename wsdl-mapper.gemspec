# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wsdl_mapper/version'

Gem::Specification.new do |spec|
  spec.name          = 'wsdl-mapper'
  spec.version       = WsdlMapper::VERSION
  spec.authors       = ['Marian Theisen']
  spec.email         = ['marian.theisen@kayoom.com']
  spec.summary       = %q{Write a short summary. Required.}
  spec.description   = %q{Write a longer description. Optional.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'minitest-focus'
  spec.add_development_dependency 'simplecov', '~> 0.13.0'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'github-markup'
  spec.add_development_dependency 'logging', '~> 2.1'
  spec.add_development_dependency 'coveralls'

  spec.add_dependency 'concurrent-ruby'
  spec.add_dependency 'faraday', '~> 0.11'
  spec.add_dependency 'nokogiri', '~> 1.7'
  spec.add_dependency 'thor', '~> 0.19'
end
