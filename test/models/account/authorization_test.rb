require 'test_helper'

class Account::AuthorizationTest < ActiveSupport::TestCase
  fixtures :accounts
  test 'validate authorize admin?' do
    account = accounts(:admin)
    assert Account::Authorization.new(account).admin?
    refute Account::Authorization.new(account).spam?
    refute Account::Authorization.new(account).default?
    assert Account::Authorization.new(account).active_and_not_disabled?
  end

  test 'validate authorize spam?' do
    account = accounts(:spammer)
    assert Account::Authorization.new(account).spam?
    refute Account::Authorization.new(account).admin?
    refute Account::Authorization.new(account).default?
    refute Account::Authorization.new(account).active_and_not_disabled?
    assert Account::Authorization.new(account).disabled?
  end

  test 'validate authorize default?' do
    account = accounts(:user)
    assert Account::Authorization.new(account).default?
    refute Account::Authorization.new(account).admin?
    refute Account::Authorization.new(account).spam?
    assert Account::Authorization.new(account).active_and_not_disabled?
  end

  test 'activate user' do
    account = accounts(:kyle)
    refute Account::Authorization.new(account).activated?
    Account::Authorization.new(account).activate!(account.activation_code)
    assert Account::Authorization.new(account).activated?
  end

  test 'deny activating user with invalid activation code' do
    account = accounts(:kyle)
    refute Account::Authorization.new(account).activated?
    Account::Authorization.new(account).activate!('dummy')
    refute Account::Authorization.new(account).activated?
  end

  test 'disable user' do
    account = accounts(:user)
    refute Account::Authorization.new(account).disabled?
    Account::Authorization.new(account).disable!
    assert Account::Authorization.new(account).disabled?
  end

  test 'mark user as spam' do
    account = accounts(:user)
    refute Account::Authorization.new(account).spam?
    account.stubs(:destroy_spam).returns(true)
    Account::Authorization.new(account).spam!
    assert Account::Authorization.new(account).spam?
  end
end
