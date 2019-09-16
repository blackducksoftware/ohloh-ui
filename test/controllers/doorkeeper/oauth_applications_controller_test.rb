# frozen_string_literal: true

require 'test_helper'

describe 'Doorkeeper::OauthApplicationsController' do
  describe 'revoke_access' do
    let(:account) { create(:account) }
    let(:token) { create(:access_token, resource_owner_id: account.id) }
    let(:oauth_application) { token.application }

    it 'wont allow without logging in' do
      get :revoke_access, account_id: account.id, id: oauth_application.id

      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'wont allow for other account' do
      login_as account

      get :revoke_access, account_id: create(:account).id, id: oauth_application.id

      must_redirect_to new_session_path
      flash[:error].must_equal I18n.t(:cant_edit_other_account)
    end

    it 'wont allow for non existing application' do
      login_as account

      get :revoke_access, account_id: create(:account).id, id: 9999

      must_respond_with :not_found
    end

    it 'must revoke access token successfully' do
      login_as account
      referer_path = edit_account_privacy_account_path(account)

      request.env['HTTP_REFERER'] = referer_path
      get :revoke_access, account_id: account.id, id: oauth_application.id

      token.reload.must_be :revoked?
      must_redirect_to referer_path
    end
  end
end
