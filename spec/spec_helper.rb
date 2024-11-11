$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'bundler/setup'
require 'webmock/rspec'
require 'simplecov'
require 'active_support'
require 'active_support/core_ext/hash'

# Configure SimpleCov before requiring our library
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
  track_files 'lib/**/*.rb'
  enable_coverage :branch
end

require 'omniauth'
require 'omniauth-oauth2'
require 'omniauth/strategies/mlh'

Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

WebMock.disable_net_connect!(allow_localhost: true)
