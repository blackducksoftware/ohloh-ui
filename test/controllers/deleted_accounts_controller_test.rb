# frozen_string_literal: true

require 'test_helper'

describe 'DeletedAccountsController' do
  let(:account) { create(:account) }

  describe 'edit' do
    it 'must render the view successfully' do
      create(:deleted_account, login: account.login, email: account.email, reasons: nil, reason_other: nil)
      account.delete
      get :edit, id: account.login

      must_render_template 'edit'
    end

    it 'must redirect to root when account is not deleted' do
      create(:deleted_account, login: account.login, email: account.email)
      get :edit, id: account.login

      must_redirect_to root_path
      flash[:error].must_equal I18n.t('deleted_accounts.edit.invalid_request')
    end

    it 'must redirect to root path when feedback time elapsed' do
      create(:deleted_account, login: account.login, email: account.email)
      account.delete
      DeletedAccount.any_instance.stubs(:feedback_time_elapsed?).returns(true)
      get :edit, id: account.login

      must_redirect_to root_path
      flash[:error].must_equal I18n.t('deleted_accounts.edit.expired')
    end

    it 'must respond with not_found when deleted account does not exist' do
      account.delete
      get :edit, id: account.login

      must_respond_with :not_found
    end
  end

  describe 'update' do
    it 'must update the given reason successfully' do
      deleted_account = create(:deleted_account, login: account.login, email: account.email,
                                                 reasons: nil, reason_other: nil)
      account.delete
      put :update, id: deleted_account.login, reasons: [1, 2, 3], reason_other: 'reason'

      must_redirect_to root_path
      assigns(:deleted_account).reasons.must_equal [1, 2, 3]
      assigns(:deleted_account).reason_other.must_equal 'reason'
      flash[:success].must_equal I18n.t('deleted_accounts.update.success')
    end

    describe 'reason not given' do
      before do
        deleted_account = create(:deleted_account, login: account.login, email: account.email,
                                                   reasons: nil, reason_other: nil)
        account.delete
        put :update, id: deleted_account.login
      end

      it 'wont update deleted_account' do
        assert_nil assigns(:deleted_account).reasons
        assert_nil assigns(:deleted_account).reason_other
      end

      it 'must render edit template' do
        must_render_template 'edit'
      end
    end

    it 'must redirect to root_path when account is present' do
      create(:deleted_account, login: account.login, email: account.email)
      put :update, id: account.login, reasons: [1], reason_other: 'reason'

      must_redirect_to root_path
      flash[:error].must_equal I18n.t('deleted_accounts.update.invalid_request')
    end

    it 'must respond with not_found when deleted account is not present' do
      account.delete
      put :update, id: account.login, reasons: [1], reason_other: 'reason'

      must_respond_with :not_found
    end

    it 'must redirect to root_path when feedback time has elapsed' do
      create(:deleted_account, login: account.login, email: account.email, reasons: nil, reason_other: nil)
      account.delete
      DeletedAccount.any_instance.stubs(:feedback_time_elapsed?).returns(true)
      put :update, id: account.login, reasons: [1], reason_other: 'reason'

      must_redirect_to root_path
      flash[:error].must_equal I18n.t('deleted_accounts.update.expired')
    end
  end
end
