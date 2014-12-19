require 'test_helper'

class Account::AuthorizeTest < ActiveSupport::TestCase
  fixtures :accounts
  test 'validate authorize admin?' do
    account = accounts(:admin)
    assert Account::Authorize.new(account).admin?
    refute Account::Authorize.new(account).spam?
    refute Account::Authorize.new(account).default?
    assert Account::Authorize.new(account).active_and_not_disabled?
  end

  test 'validate authorize spam?' do
    account = accounts(:spammer)
    assert Account::Authorize.new(account).spam?
    refute Account::Authorize.new(account).admin?
    refute Account::Authorize.new(account).default?
    refute Account::Authorize.new(account).active_and_not_disabled?
    assert Account::Authorize.new(account).disabled?
  end

  test 'validate authorize default?' do
    account = accounts(:user)
    assert Account::Authorize.new(account).default?
    refute Account::Authorize.new(account).admin?
    refute Account::Authorize.new(account).spam?
    assert Account::Authorize.new(account).active_and_not_disabled?
  end

  test 'activate user' do
    account = accounts(:unactivated)
    refute Account::Authorize.new(account).activated?
    Account::Authorize.new(account).activate!(account.activation_code)
    assert Account::Authorize.new(account).activated?
  end

  test 'deny activating user with invalid activation code' do
    account = accounts(:unactivated)
    refute Account::Authorize.new(account).activated?
    Account::Authorize.new(account).activate!('dummy')
    refute Account::Authorize.new(account).activated?
  end

  test 'disable user' do
    account = accounts(:user)
    refute Account::Authorize.new(account).disabled?
    Account::Authorize.new(account).disable!
    assert Account::Authorize.new(account).disabled?
  end

  test 'mark user as spam' do
    account = accounts(:user)
    refute Account::Authorize.new(account).spam?
    Account.transaction do
      Account::Authorize.new(account).spam! rescue ''
    end
    assert Account::Authorize.new(account).spam?
  end
end
