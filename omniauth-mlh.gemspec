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
  spec.description   = 'Official OmniAuth strategy for MyMLH v4 API.'
  spec.homepage      = 'http://github.com/mlh/omniauth-mlh'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.2.0'

  spec.executables    = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.files          = `git ls-files`.split("\n")
  spec.test_files     = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.require_paths = ['lib']

  spec.add_dependency 'oauth2', '~> 2.0.9'
  spec.add_dependency 'omniauth', '~> 2.1.1'
  spec.add_dependency 'omniauth-oauth2', '~> 1.8.0'

  spec.add_development_dependency 'rack-test', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 13.1'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.57'
  spec.add_development_dependency 'rubocop-performance', '~> 1.19'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.24'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'webmock', '~> 3.19'
end
