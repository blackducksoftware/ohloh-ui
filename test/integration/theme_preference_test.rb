# frozen_string_literal: true

require 'test_helper'

class ThemePreferenceTest < ActionDispatch::IntegrationTest
  let(:user_account) { create(:account, password: TEST_PASSWORD) }

  describe 'Theme Preference API' do
    it 'denies access to unauthenticated users' do
      other_account = create(:account)

      get "/accounts/#{other_account.id}/theme_preference.json"

      assert_response :unauthorized
    end

    it 'returns saved dark theme preference for authenticated users' do
      login_as user_account
      user_account.theme_preference = 'dark'

      get "/accounts/#{user_account.id}/theme_preference.json"

      assert_response :success
      response_body = JSON.parse(@response.body)
      assert_equal('dark', response_body['theme_preference'])
    end

    it 'returns nil as default when no preference is set (sparse storage)' do
      login_as user_account

      get "/accounts/#{user_account.id}/theme_preference.json"

      assert_response :success
      response_body = JSON.parse(@response.body)
      assert_nil(response_body['theme_preference'])
    end

    it 'allows authenticated users to set dark theme preference' do
      login_as user_account

      post "/accounts/#{user_account.id}/set_theme_preference",
           params: { theme: 'dark' },
           headers: { 'X-CSRF-Token' => csrf_token }

      assert_response :success
      response_body = JSON.parse(@response.body)
      assert_equal(true, response_body['success'])
      assert_equal('dark', response_body['theme'])

      assert_equal('dark', user_account.reload.theme_preference)
    end

    it 'allows authenticated users to set light theme preference (deletes database entry)' do
      login_as user_account
      user_account.theme_preference = 'dark'

      post "/accounts/#{user_account.id}/set_theme_preference",
           params: { theme: 'light' },
           headers: { 'X-CSRF-Token' => csrf_token }

      assert_response :success
      response_body = JSON.parse(@response.body)
      assert_equal(true, response_body['success'])

      assert_nil(user_account.reload.theme_preference)
      assert_nil(Setting.find_by(key: "account_#{user_account.id}_theme_preference"))
    end

    it 'persists theme preference across page loads' do
      login_as user_account
      user_account.theme_preference = 'dark'

      get "/accounts/#{user_account.id}/theme_preference.json"
      response_body1 = JSON.parse(@response.body)

      # Simulate another page load
      get "/accounts/#{user_account.id}/theme_preference.json"
      response_body2 = JSON.parse(@response.body)

      assert_equal('dark', response_body1['theme_preference'])
      assert_equal('dark', response_body2['theme_preference'])
    end

    it 'allows switching theme preferences (dark to light deletes entry)' do
      login_as user_account

      post "/accounts/#{user_account.id}/set_theme_preference",
           params: { theme: 'dark' },
           headers: { 'X-CSRF-Token' => csrf_token }

      assert_equal('dark', user_account.reload.theme_preference)

      post "/accounts/#{user_account.id}/set_theme_preference",
           params: { theme: 'light' },
           headers: { 'X-CSRF-Token' => csrf_token }

      assert_nil(user_account.reload.theme_preference)
      assert_nil(Setting.find_by(key: "account_#{user_account.id}_theme_preference"))
    end

    it 'rejects requests from unauthenticated users' do
      other_account = create(:account)

      post "/accounts/#{other_account.id}/set_theme_preference",
           params: { theme: 'dark' }

      assert_redirected_to new_session_path
    end

    it 'returns JSON response with proper content type' do
      login_as user_account

      post "/accounts/#{user_account.id}/set_theme_preference",
           params: { theme: 'dark' },
           headers: { 'X-CSRF-Token' => csrf_token }

      assert_response :success
      assert_equal('application/json', response.media_type)
    end
  end

  private

  def csrf_token
    get root_path
    session_data = request.session
    session_data['_csrf_token'] ||= SecureRandom.base64(32)
  end
end
