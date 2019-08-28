# frozen_string_literal: true

require 'test_helper'

class Account::AccessTest < ActiveSupport::TestCase
  let(:nil_account) { NilAccount.new }
  let(:account) { create(:account) }
  let(:admin) { create(:admin) }
  let(:spammer) { create(:spammer) }
  let(:unactivated) { create(:unactivated) }
  let(:disabled) { create(:disabled_account) }
  let(:nil_account_access) { Account::Access.new(nil_account) }
  let(:account_access) { Account::Access.new(account) }
  let(:admin_access) { Account::Access.new(admin) }
  let(:spammer_access) { Account::Access.new(spammer) }
  let(:unactivated_access) { Account::Access.new(unactivated) }
  let(:disabled_access) { Account::Access.new(disabled) }

  describe 'admin?' do
    it 'should return true for admin' do
      admin_access.admin?.must_equal true
    end

    it 'should return false for non-admin accounts' do
      account_access.admin?.must_equal false
      spammer_access.admin?.must_equal false
      unactivated_access.admin?.must_equal false
      disabled_access.admin?.must_equal false
    end

    it 'should return false for nil_account' do
      nil_account_access.admin?.must_equal false
    end
  end

  describe 'default?' do
    it 'should return true for normal accounts' do
      account_access.default?.must_equal true
      unactivated_access.default?.must_equal true
    end

    it 'should return false for non-default accounts' do
      admin_access.default?.must_equal false
      spammer_access.default?.must_equal false
      disabled_access.default?.must_equal false
    end

    it 'should return false for nil_account' do
      nil_account_access.default?.must_equal false
    end
  end

  describe 'activated?' do
    it 'should return false for unactivated_account' do
      unactivated_access.activated?.must_equal false
    end

    it 'should return true for activated accounts' do
      admin_access.activated?.must_equal true
      account_access.activated?.must_equal true
      spammer_access.activated?.must_equal true
      disabled_access.activated?.must_equal true
    end

    it 'should return false for nil_account' do
      nil_account_access.activated?.must_equal false
    end
  end

  describe 'disabled?' do
    it 'should return true for spam and disabled accounts' do
      disabled_access.disabled?.must_equal true
      spammer_access.disabled?.must_equal true
    end

    it 'should return false for activated accounts' do
      admin_access.disabled?.must_equal false
      account_access.disabled?.must_equal false
      unactivated_access.disabled?.must_equal false
    end

    it 'should return false for nil_account' do
      nil_account_access.disabled?.must_equal false
    end
  end

  describe 'spam?' do
    it 'should return true for spam account' do
      spammer_access.spam?.must_equal true
    end

    it 'should return false for activated accounts' do
      disabled_access.spam?.must_equal false
      admin_access.spam?.must_equal false
      account_access.spam?.must_equal false
      unactivated_access.spam?.must_equal false
    end

    it 'should return false for nil_account' do
      nil_account_access.spam?.must_equal false
    end
  end

  describe 'active_and_not_disabled?' do
    it 'should return true for admin and normal account' do
      account_access.active_and_not_disabled?.must_equal true
      admin_access.active_and_not_disabled?.must_equal true
    end

    it 'should return false for admin and normal account' do
      unactivated_access.active_and_not_disabled?.must_equal false
      spammer_access.active_and_not_disabled?.must_equal false
      disabled_access.active_and_not_disabled?.must_equal false
    end

    it 'should return false for nil_account' do
      nil_account_access.active_and_not_disabled?.must_equal false
    end
  end

  describe 'activate!' do
    it 'should activate unactivated account' do
      unactivated_access.activated?.must_equal false
      assert_difference(['ActionMailer::Base.deliveries.size'], 1) do
        unactivated_access.activate!(unactivated.activation_code)
      end
    end

    it 'should deny activation user with invalid activation code' do
      unactivated_access.activate!('dummy')
      assert_difference(['ActionMailer::Base.deliveries.size'], 0) do
        unactivated_access.activated?.must_equal false
      end
    end

    it 'should raise exception for nil_account' do
      assert_difference(['ActionMailer::Base.deliveries.size'], 0) do
        proc { nil_account_access.activate!('dummy') }.must_raise NoMethodError
      end
    end
  end

  describe 'disable!' do
    it 'should disable account' do
      account_access.disabled?.must_equal false
      account_access.disable!
      Account::Access.new(account).disabled?.must_equal true
    end

    it 'should raise exception for nil_account' do
      proc { nil_account_access.disable! }.must_raise NoMethodError
    end
  end

  describe 'spam!' do
    it 'should mark account as spam' do
      account_access.spam?.must_equal false
      account_access.spam!
      Account::Access.new(account).spam?.must_equal true
    end

    it 'should raise exception for nil_account' do
      proc { nil_account_access.spam! }.must_raise NoMethodError
    end
  end
end
