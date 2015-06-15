require 'test_helper'

describe 'Accounts::VerificationsController' do
  describe 'new' do
    it 'must require user to be logged in' do
      get :new, account_id: create(:account).id

      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'must handle disabled account' do
      account = create(:disabled_account)
      login_as account

      get :new, account_id: account.id

      must_respond_with :not_found
    end

    it 'wont allow verifying other account' do
      login_as create(:account)
      get :new, account_id: create(:account).id

      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'must render the view successfully' do
      account = create(:account)
      login_as account

      get :new, account_id: account.id

      must_render_template :new
    end
  end
end
