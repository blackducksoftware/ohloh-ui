# frozen_string_literal: true

require 'test_helper'

# Since we customize the doorkeeper view, we need tests to ensure that it renders correctly.
# If an undefined method error is encountered, see OauthLayoutHelper.
class Doorkeeper::AuthorizationsControllerTest < ActionController::TestCase
  describe 'new' do
    let(:user) { create(:account) }
    let(:redirect_uri) { 'http://localhost/callback' }
    let(:oauth_app) { create(:oauth_application, redirect_uri: redirect_uri, scopes: 'public') }
    let(:api_key) { create(:api_key, account: user, oauth_application: oauth_app) }
    let(:client_id) { api_key.oauth_application.uid }
    before { login_as user }

    it 'must render the page successfully ' do
      get :new, params: { client_id: client_id, redirect_uri: redirect_uri, response_type: :code, scope: 'public' }

      assert_response :success
      assert_template 'new'
    end

    it 'wont render form when redirect_uri is missing' do
      get :new, params: { client_id: client_id, response_type: :code, scope: 'public' }

      assert_template 'error'
    end

    it 'wont render form when client_id is missing' do
      get :new, params: { redirect_uri: redirect_uri, response_type: :code, scope: 'public' }

      assert_template 'error'
    end
  end
end
