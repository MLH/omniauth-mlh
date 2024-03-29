# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'omniauth-mlh/version'

Gem::Specification.new do |spec|
  spec.name          = 'omniauth-mlh'
  spec.version       = OmniAuth::MLH::VERSION
  spec.authors       = ['Major League Hacking (MLH)']
  spec.email         = ['hi@mlh.io']

  spec.summary       = 'Official OmniAuth strategy for MyMLH.'
  spec.description   = 'Official OmniAuth strategy for MyMLH.'
  spec.homepage      = 'http://github.com/mlh/omniauth-mlh'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.7.0'

  spec.executables    = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.files          = `git ls-files`.split("\n")
  spec.test_files     = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.require_paths = ['lib']

  spec.add_dependency 'oauth2', '~> 2.0.9'
  spec.add_dependency 'omniauth', '~> 2.1.1'
  spec.add_dependency 'omniauth-oauth2', '~> 1.8.0'

  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rake', '~> 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'
end
