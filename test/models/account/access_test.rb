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
      _(admin_access.admin?).must_equal true
    end

    it 'should return false for non-admin accounts' do
      _(account_access.admin?).must_equal false
      _(spammer_access.admin?).must_equal false
      _(unactivated_access.admin?).must_equal false
      _(disabled_access.admin?).must_equal false
    end

    it 'should return false for nil_account' do
      _(nil_account_access.admin?).must_equal false
    end
  end

  describe 'default?' do
    it 'should return true for normal accounts' do
      _(account_access.default?).must_equal true
      _(unactivated_access.default?).must_equal true
    end

    it 'should return false for non-default accounts' do
      _(admin_access.default?).must_equal false
      _(spammer_access.default?).must_equal false
      _(disabled_access.default?).must_equal false
    end

    it 'should return false for nil_account' do
      _(nil_account_access.default?).must_equal false
    end
  end

  describe 'activated?' do
    it 'should return false for unactivated_account' do
      _(unactivated_access.activated?).must_equal false
    end

    it 'should return true for activated accounts' do
      _(admin_access.activated?).must_equal true
      _(account_access.activated?).must_equal true
      _(spammer_access.activated?).must_equal true
      _(disabled_access.activated?).must_equal true
    end

    it 'should return false for nil_account' do
      _(nil_account_access.activated?).must_equal false
    end
  end

  describe 'disabled?' do
    it 'should return true for spam and disabled accounts' do
      _(disabled_access.disabled?).must_equal true
      _(spammer_access.disabled?).must_equal true
    end

    it 'should return false for activated accounts' do
      _(admin_access.disabled?).must_equal false
      _(account_access.disabled?).must_equal false
      _(unactivated_access.disabled?).must_equal false
    end

    it 'should return false for nil_account' do
      _(nil_account_access.disabled?).must_equal false
    end
  end

  describe 'spam?' do
    it 'should return true for spam account' do
      _(spammer_access.spam?).must_equal true
    end

    it 'should return false for activated accounts' do
      _(disabled_access.spam?).must_equal false
      _(admin_access.spam?).must_equal false
      _(account_access.spam?).must_equal false
      _(unactivated_access.spam?).must_equal false
    end

    it 'should return false for nil_account' do
      _(nil_account_access.spam?).must_equal false
    end
  end

  describe 'active_and_not_disabled?' do
    it 'should return true for admin and normal account' do
      _(account_access.active_and_not_disabled?).must_equal true
      _(admin_access.active_and_not_disabled?).must_equal true
    end

    it 'should return false for admin and normal account' do
      _(unactivated_access.active_and_not_disabled?).must_equal false
      _(spammer_access.active_and_not_disabled?).must_equal false
      _(disabled_access.active_and_not_disabled?).must_equal false
    end

    it 'should return false for nil_account' do
      _(nil_account_access.active_and_not_disabled?).must_equal false
    end
  end

  describe 'activate!' do
    it 'should activate unactivated account' do
      _(unactivated_access.activated?).must_equal false
      assert_difference(['ActionMailer::Base.deliveries.size'], 1) do
        unactivated_access.activate!(unactivated.activation_code)
      end
    end

    it 'should deny activation user with invalid activation code' do
      unactivated_access.activate!('dummy')
      assert_difference(['ActionMailer::Base.deliveries.size'], 0) do
        _(unactivated_access.activated?).must_equal false
      end
    end

    it 'should raise exception for nil_account' do
      assert_difference(['ActionMailer::Base.deliveries.size'], 0) do
        _(proc { nil_account_access.activate!('dummy') }).must_raise NoMethodError
      end
    end
  end

  describe 'disable!' do
    it 'should disable account' do
      _(account_access.disabled?).must_equal false
      account_access.disable!
      _(Account::Access.new(account).disabled?).must_equal true
    end

    it 'should raise exception for nil_account' do
      _(proc { nil_account_access.disable! }).must_raise NoMethodError
    end
  end

  describe 'spam!' do
    it 'should mark account as spam' do
      _(account_access.spam?).must_equal false
      account_access.spam!
      _(Account::Access.new(account).spam?).must_equal true
    end

    it 'should raise exception for nil_account' do
      _(proc { nil_account_access.spam! }).must_raise NoMethodError
    end
  end

  describe 'manual_or_oauth_verified' do
    it 'must verify old Firebase records' do
      account = create(:account)
      account.verifications.destroy_all

      _(account.access).wont_be :manual_or_oauth_verified?
      FirebaseVerification.create! unique_id: Faker::Internet.password, account: account
      _(account.access).must_be :manual_or_oauth_verified?
    end
  end
end
