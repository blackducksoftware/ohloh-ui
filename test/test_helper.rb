ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
SimpleCov.start 'rails'

class ActiveSupport::TestCase
end
