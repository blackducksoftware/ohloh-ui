# frozen_string_literal: true

require 'test_helper'

# Since we customize the doorkeeper view, we need tests to ensure that it renders correctly.
# If an undefined method error is encountered, see OauthLayoutHelper.
describe 'Doorkeeper::AuthorizationsController' do
  describe 'new' do
    let(:api_key) { create(:api_key) }
    let(:client_id) { api_key.oauth_application.uid }
    let(:redirect_uri) { api_key.oauth_application.redirect_uri }
    before { login_as create(:account) }

    it 'must render the page successfully ' do
      get :new, client_id: client_id, redirect_uri: redirect_uri, response_type: :code

      must_respond_with :success
      must_render_template 'new'
    end

    it 'wont render form when redirect_uri is missing' do
      get :new, client_id: client_id, response_type: :code

      must_render_template 'error'
    end

    it 'wont render form when client_id is missing' do
      get :new, redirect_uri: redirect_uri, response_type: :code

      must_render_template 'error'
    end
  end
end
