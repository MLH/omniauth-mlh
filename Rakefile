#!/usr/bin/env rake
# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new
RuboCop::RakeTask.new

desc 'Run specs'
task default: %i[spec rubocop]
