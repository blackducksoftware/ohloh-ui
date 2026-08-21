# frozen_string_literal: true

require 'test_helper'

class SamlControllerTest < ActionController::TestCase
  let(:admin) { create(:admin) }
  let(:user) { create(:account) }

  def build_omniauth_auth(email)
    OmniAuth::AuthHash.new(
      provider: 'saml',
      uid: email,
      info: OmniAuth::AuthHash::InfoHash.new(email: email)
    )
  end

  describe 'Okta SAML authentication' do
    it 'accepts okta auth successfully when emails match' do
      token = SecureRandom.hex(16)
      email = admin.email
      cache_data = { email: email, return_to: '/projects/123' }

      Rails.cache.stubs(:read).with("saml_pending:#{token}").returns(cache_data)
      Rails.cache.stubs(:delete).with("saml_pending:#{token}").returns(true)

      request.env['omniauth.auth'] = build_omniauth_auth(email)

      post :callback, params: { RelayState: token }
      assert_redirected_to cache_data[:return_to]
    end

    it 'rejects okta auth when okta email differs from login email' do
      token = SecureRandom.hex(16)
      email = admin.email
      different_email = 'different@example.com'
      cache_data = { email: email, return_to: '/projects/123' }

      Rails.cache.stubs(:read).with("saml_pending:#{token}").returns(cache_data)

      request.env['omniauth.auth'] = build_omniauth_auth(different_email)

      post :callback, params: { RelayState: token }

      assert_redirected_to new_session_path
      _(flash[:alert]).must_equal I18n.t('flashes.saml_email_mismatch')
    end

    it 'handles okta auth failure when auth data is missing' do
      token = SecureRandom.hex(16)
      cache_data = { email: admin.email, return_to: '/projects/123' }

      Rails.cache.stubs(:read).with("saml_pending:#{token}").returns(cache_data)

      request.env['omniauth.auth'] = OmniAuth::AuthHash.new(
        provider: 'saml',
        uid: nil,
        info: OmniAuth::AuthHash::InfoHash.new({})
      )

      post :callback, params: { RelayState: token }

      assert_redirected_to new_session_path
      _(flash[:alert]).must_equal I18n.t('flashes.saml_email_mismatch')
    end

    it 'redirects to original page (return_to) after okta re-auth' do
      token = SecureRandom.hex(16)
      email = admin.email
      original_page = '/projects/search?query=ruby'
      cache_data = { email: email, return_to: original_page }

      Rails.cache.stubs(:read).with("saml_pending:#{token}").returns(cache_data)
      Rails.cache.stubs(:delete)

      request.env['omniauth.auth'] = build_omniauth_auth(email)

      post :callback, params: { RelayState: token }

      assert_redirected_to original_page
    end

    it 'uses uid as fallback when info.email is nil' do
      token = SecureRandom.hex(16)
      email = admin.email
      cache_data = { email: email, return_to: '/accounts/me' }

      Rails.cache.stubs(:read).with("saml_pending:#{token}").returns(cache_data)
      Rails.cache.stubs(:delete).with("saml_pending:#{token}").returns(true)

      request.env['omniauth.auth'] = OmniAuth::AuthHash.new(
        provider: 'saml',
        uid: email,
        info: OmniAuth::AuthHash::InfoHash.new({})
      )

      post :callback, params: { RelayState: token }

      assert_redirected_to Clearance.configuration.redirect_url
    end
  end

  describe 'Okta session expiry' do
    it 'okta session expires and forces re-authentication' do
      token = SecureRandom.hex(16)

      @controller.stubs(:current_user).returns(admin)
      Rails.cache.stubs(:write)

      get :callback, params: { RelayState: token }, session: { okta_authed_at: 25.hours.ago.to_i }

      assert_response :success
      assert_template 'sessions/saml_redirect'
    end

    it 'excluded admin bypasses session expiry check' do
      token = SecureRandom.hex(16)
      cache_data = { email: admin.email, return_to: '/test' }

      @controller.stubs(:current_user).returns(admin)
      old_env = ENV.fetch('OKTA_AUTH_EXCLUDED_ADMINS', nil)
      ENV['OKTA_AUTH_EXCLUDED_ADMINS'] = admin.email
      Rails.cache.stubs(:read).returns(cache_data)
      Rails.cache.stubs(:delete)

      begin
        request.env['omniauth.auth'] = build_omniauth_auth(admin.email)
        get :callback, params: { RelayState: token }, session: { okta_authed_at: 25.hours.ago.to_i }
        assert_redirected_to cache_data[:return_to]
      ensure
        ENV['OKTA_AUTH_EXCLUDED_ADMINS'] = old_env
      end
    end
  end
end
