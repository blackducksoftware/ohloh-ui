ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'dotenv'
Dotenv.overload '.env.test'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails'

ActiveRecord::Migration.maintain_test_schema!

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  def login_as(account)
    @controller.expects(:current_user).times(0..999_999).returns(account)
  end
end
