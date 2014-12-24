require 'test_helper'

class Account::AccessTest < ActiveSupport::TestCase
  fixtures :accounts
  test 'validate authorize admin?' do
    account = accounts(:admin)
    assert Account::Access.new(account).admin?
    refute Account::Access.new(account).spam?
    refute Account::Access.new(account).default?
    assert Account::Access.new(account).active_and_not_disabled?
  end

  test 'validate authorize spam?' do
    account = accounts(:spammer)
    assert Account::Access.new(account).spam?
    refute Account::Access.new(account).admin?
    refute Account::Access.new(account).default?
    refute Account::Access.new(account).active_and_not_disabled?
    assert Account::Access.new(account).disabled?
  end

  test 'validate authorize default?' do
    account = accounts(:user)
    assert Account::Access.new(account).default?
    refute Account::Access.new(account).admin?
    refute Account::Access.new(account).spam?
    assert Account::Access.new(account).active_and_not_disabled?
  end

  test 'activate user' do
    account = accounts(:unactivated)
    refute Account::Access.new(account).activated?
    Account::Access.new(account).activate!(account.activation_code)
    assert Account::Access.new(account).activated?
  end

  test 'deny activating user with invalid activation code' do
    account = accounts(:unactivated)
    refute Account::Access.new(account).activated?
    Account::Access.new(account).activate!('dummy')
    refute Account::Access.new(account).activated?
  end

  test 'disable user' do
    account = accounts(:user)
    refute Account::Access.new(account).disabled?
    Account::Access.new(account).disable!
    assert Account::Access.new(account).disabled?
  end

  test 'mark user as spam' do
    account = accounts(:user)
    refute Account::Access.new(account).spam?
    Account.transaction do
      Account::Access.new(account).spam! # rescue ''
    end
    assert Account::Access.new(account).spam?
  end

  test 'should rails exception when account is nil' do
    assert_raise(RuntimeError) do
      Account::Access.new(nil)
    end
  end
end
