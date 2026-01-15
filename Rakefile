# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be
# available to Rake.

require File.expand_path('config/application', __dir__)

Rails.application.load_tasks

# Ensure middleware tests are included in the default test task
require 'rake/testtask'

Rake::Task[:test].clear if Rake::Task.task_defined?(:test)

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb'].exclude('test/system/**/*')
  t.verbose = false
  t.warning = false
end
