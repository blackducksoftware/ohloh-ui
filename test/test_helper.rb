ENV['RAILS_ENV'] ||= 'test'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'dotenv'
Dotenv.overload '.env.test'

ActiveRecord::Migration.maintain_test_schema!

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  def login_as(account)
    @controller.session[:account_id] = account ? account.id : nil
  end
end
