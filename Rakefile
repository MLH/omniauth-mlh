#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new
RuboCop::RakeTask.new do |task|
    task.patterns = ['**/*.rb']
    task.options = ['-c', '.rubocop.yml']
end

desc 'Run specs'
task default: :spec
