require 'test_helper'

class Account::AccessTest < ActiveSupport::TestCase
  let(:nil_account) { NilAccount.new }
  let(:account) { create(:account) }
  let(:admin) { create(:admin) }
  let(:spammer) { create(:spammer) }
  let(:unactivated) { create(:unactivated) }
  let(:disabled) { create(:disabled_account) }
  let(:nil_account_acess) { Account::Access.new(nil_account) }
  let(:account_acess) { Account::Access.new(account) }
  let(:admin_acess) { Account::Access.new(admin) }
  let(:spammer_acess) { Account::Access.new(spammer) }
  let(:unactivated_acess) { Account::Access.new(unactivated) }
  let(:disabled_acess) { Account::Access.new(disabled) }

  describe 'admin?' do
    it 'should return true for admin' do
      admin_acess.admin?.must_equal true
    end

    it 'should return false for non-admin accounts' do
      account_acess.admin?.must_equal false
      spammer_acess.admin?.must_equal false
      unactivated_acess.admin?.must_equal false
      disabled_acess.admin?.must_equal false
    end

    it 'should return false for nil_account' do
      nil_account_acess.admin?.must_equal false
    end
  end

  describe 'default?' do
    it 'should return true for normal accounts' do
      account_acess.default?.must_equal true
      unactivated_acess.default?.must_equal true
    end

    it 'should return false for non-default accounts' do
      admin_acess.default?.must_equal false
      spammer_acess.default?.must_equal false
      disabled_acess.default?.must_equal false
    end

    it 'should return false for nil_account' do
      nil_account_acess.default?.must_equal false
    end
  end

  describe 'activated?' do
    it 'should return false for unactivated_account' do
      unactivated_acess.activated?.must_equal false
    end

    it 'should return true for activated accounts' do
      admin_acess.activated?.must_equal true
      account_acess.activated?.must_equal true
      spammer_acess.activated?.must_equal true
      disabled_acess.activated?.must_equal true
    end

    it 'should return false for nil_account' do
      nil_account_acess.activated?.must_equal false
    end
  end

  describe 'disabled?' do
    it 'should return true for spam and disabled accounts' do
      disabled_acess.disabled?.must_equal true
      spammer_acess.disabled?.must_equal true
    end

    it 'should return false for activated accounts' do
      admin_acess.disabled?.must_equal false
      account_acess.disabled?.must_equal false
      unactivated_acess.disabled?.must_equal false
    end

    it 'should return false for nil_account' do
      nil_account_acess.disabled?.must_equal false
    end
  end

  describe 'spam?' do
    it 'should return true for spam account' do
      spammer_acess.spam?.must_equal true
    end

    it 'should return false for activated accounts' do
      disabled_acess.spam?.must_equal false
      admin_acess.spam?.must_equal false
      account_acess.spam?.must_equal false
      unactivated_acess.spam?.must_equal false
    end

    it 'should return false for nil_account' do
      nil_account_acess.spam?.must_equal false
    end
  end

  describe 'active_and_not_disabled?' do
    it 'should return true for admin and normal account' do
      account_acess.active_and_not_disabled?.must_equal true
      admin_acess.active_and_not_disabled?.must_equal true
    end

    it 'should return false for admin and normal account' do
      unactivated_acess.active_and_not_disabled?.must_equal false
      spammer_acess.active_and_not_disabled?.must_equal false
      disabled_acess.active_and_not_disabled?.must_equal false
    end

    it 'should return false for nil_account' do
      nil_account_acess.active_and_not_disabled?.must_equal false
    end
  end

  describe 'activate!' do
    it 'should activate unactivated account' do
      unactivated_acess.activated?.must_equal false
      unactivated_acess.activate!(unactivated.activation_code)
    end

    it 'should deny activation user with invalid activation code' do
      unactivated_acess.activate!('dummy')
      unactivated_acess.activated?.must_equal false
    end

    it 'should raise exception for nil_account' do
      proc { nil_account_acess.activate!('dummy') }.must_raise NoMethodError
    end
  end

  describe 'disable!' do
    it 'should disable account' do
      account_acess.disabled?.must_equal false
      account_acess.disable!
      account_acess.reload.disabled?.must_equal true
    end

    it 'should raise exception for nil_account' do
      proc { nil_account_acess.disable! }.must_raise NoMethodError
    end
  end

  describe 'spam!' do
    it 'should mark account as spam' do
      account_acess.spam?.must_equal false
      account_acess.spam!
      account_acess.reload.spam?.must_equal true
    end

    it 'should raise exception for nil_account' do
      proc { nil_account_acess.spam! }.must_raise NoMethodError
    end
  end

  describe 'reload' do
    it 'should reload the object' do
      account_acess.admin?.must_equal false
      account.update_column(:level, 10)

      account_acess.admin?.must_equal false
      account_acess.reload.admin?.must_equal true
    end
  end
end
