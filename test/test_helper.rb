ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails'

ActiveRecord::Migration.maintain_test_schema!

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
end
