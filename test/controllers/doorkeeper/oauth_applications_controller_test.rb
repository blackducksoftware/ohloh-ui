# frozen_string_literal: true

require 'test_helper'

class Doorkeeper::OauthApplicationsControllerTest < ActionController::TestCase
  describe 'revoke_access' do
    let(:account) { create(:account) }
    let(:token) { create(:access_token, resource_owner_id: account.id) }
    let(:oauth_application) { token.application }

    it 'wont allow without logging in' do
      get :revoke_access, params: { account_id: account.id, id: oauth_application.id }

      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'wont allow for other account' do
      login_as account

      get :revoke_access, params: { account_id: create(:account).id, id: oauth_application.id }

      assert_redirected_to new_session_path
      _(flash[:error]).must_equal I18n.t(:cant_edit_other_account)
    end

    it 'wont allow for non existing application' do
      login_as account

      get :revoke_access, params: { account_id: create(:account).id, id: 9999 }

      assert_response :not_found
    end

    it 'must revoke access token successfully' do
      login_as account
      referer_path = edit_account_privacy_account_path(account)

      request.env['HTTP_REFERER'] = referer_path
      get :revoke_access, params: { account_id: account.id, id: oauth_application.id }

      _(token.reload).must_be :revoked?
      assert_redirected_to referer_path
    end
  end
end
