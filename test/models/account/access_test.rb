require 'test_helper'

class Account::AccessTest < ActiveSupport::TestCase
  it 'validate authorize admin?' do
    account = create(:admin)
    Account::Access.new(account).must_be :admin?
    Account::Access.new(account).wont_be :spam?
    Account::Access.new(account).wont_be :default?
    Account::Access.new(account).must_be :active_and_not_disabled?
  end

  it 'validate authorize spam?' do
    account = accounts(:spammer)
    Account::Access.new(account).must_be :spam?
    Account::Access.new(account).wont_be :admin?
    Account::Access.new(account).wont_be :default?
    Account::Access.new(account).wont_be :active_and_not_disabled?
    Account::Access.new(account).must_be :disabled?
  end

  it 'validate authorize default?' do
    account = create(:account)
    Account::Access.new(account).must_be :default?
    Account::Access.new(account).wont_be :admin?
    Account::Access.new(account).wont_be :spam?
    Account::Access.new(account).must_be :active_and_not_disabled?
  end

  it 'activate user' do
    account = accounts(:unactivated)
    Account::Access.new(account).wont_be :activated?
    Account::Access.new(account).activate!(account.activation_code)
    Account::Access.new(account).must_be :activated?
  end

  it 'deny activating user with invalid activation code' do
    account = accounts(:unactivated)
    Account::Access.new(account).wont_be :activated?
    Account::Access.new(account).activate!('dummy')
    Account::Access.new(account).wont_be :activated?
  end

  it 'disable user' do
    account = create(:account)
    Account::Access.new(account).wont_be :disabled?
    Account::Access.new(account).disable!
    Account::Access.new(account).must_be :disabled?
  end

  it 'mark user as spam' do
    account = create(:account)
    Account::Access.new(account).wont_be :spam?
    Account.transaction do
      Account::Access.new(account).spam! # rescue ''
    end
    Account::Access.new(account).must_be :spam?
  end

  it 'should rails exception when account is nil' do
    -> { Account::Access.new(nil) }.must_raise(RuntimeError)
  end
end
