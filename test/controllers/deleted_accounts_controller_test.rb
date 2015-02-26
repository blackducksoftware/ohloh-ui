require 'test_helper'

describe 'DeletedAccountsController' do
  let(:account) { create(:account) }

  describe 'delete_feedback' do
    it 'should not update deleted_account if reason is not given' do
      deleted_user = create(:deleted_account, login: account.login, email: account.email,
                                              reasons: nil, reason_other: nil)
      account.delete
      post :delete_feedback, login: deleted_user.login

      must_respond_with :ok
      assigns(:deleted_account).reasons.must_equal nil
      assigns(:deleted_account).reason_other.must_equal nil
    end

    it 'should render view if request is a get request' do
      create(:deleted_account, login: account.login, email: account.email, reasons: nil, reason_other: nil)
      account.delete
      get :delete_feedback, login: account.login

      must_respond_with :ok
      assigns(:deleted_account).reasons.must_equal nil
    end

    it 'should update deleted_account with the reason given' do
      deleted_user = create(:deleted_account, login: account.login, email: account.email,
                                              reasons: nil, reason_other: nil)
      account.delete
      post :delete_feedback, login: deleted_user.login, reasons: [1, 2, 3], reason_other: 'reason'

      must_redirect_to message_path
      assigns(:deleted_account).reasons.must_equal [1, 2, 3]
      assigns(:deleted_account).reason_other.must_equal 'reason'
      flash[:success].must_equal I18n.t('deleted_accounts.delete_feedback.success')
    end

    it 'should redirect to message path when feedback time elapsed' do
      account.delete
      post :delete_feedback, login: account.login, reasons: [1, 2, 3], reason_other: 'reason'

      must_redirect_to message_path
      assigns(:deleted_account).must_equal nil
      flash[:error].must_equal I18n.t('deleted_accounts.delete_feedback.invalid_request')
    end

    it 'should redirect to message path when feedback time elapsed' do
      create(:deleted_account, login: account.login, email: account.email, reasons: nil, reason_other: nil)
      account.delete
      DeletedAccount.any_instance.stubs(:feedback_time_elapsed?).returns(true)
      post :delete_feedback, login: account.login, reasons: [1, 2, 3], reason_other: 'reason'

      must_redirect_to message_path
      flash[:error].must_equal I18n.t('deleted_accounts.delete_feedback.expired')
    end
  end
end
