# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __dir__)

require 'spinach/capybara'
require 'capybara/rails'
require 'capybara/minitest'
require 'capybara/minitest/spec'
require 'mocha/mini_test'
require 'database_cleaner'

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  Spinach::FeatureSteps.include Rails.application.routes.url_helpers

  DatabaseCleaner.strategy = :truncation
  Capybara.javascript_driver = :selenium_chrome_headless

  Spinach.hooks.before_scenario do
    DatabaseCleaner.start
  end

  Spinach.hooks.after_scenario do
    DatabaseCleaner.clean
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

Minitest::Spec.class_eval do
  include Capybara::Minitest::Assertions
end
