ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails'
require 'dotenv'
Dotenv.overload '.env.test'

ActiveRecord::Migration.maintain_test_schema!

class ActiveSupport::TestCase
  fixtures :all
  include FactoryGirl::Syntax::Methods
  extend MiniTest::Spec::DSL

  def login_as(account)
    @controller.session[:account_id] = account ? account.id : nil
  end

  def fixup
  end

  def as(user)
    login_as user
    yield if block_given?
  end
  alias_method :edit_as, :as

  # TODO: Fix when integrating accounts.
  def with_editor(_user)
    yield if block_given?
  end
end
