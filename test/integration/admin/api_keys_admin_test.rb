# frozen_string_literal: true

require 'test_helper'

class ApiKeysAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin) }

  # This works for the UI.......
  it 'index loads' do
    create(:api_key, status: ApiKey::STATUS_OK)
    create(:api_key, status: ApiKey::STATUS_LIMIT_EXCEEDED)
    create(:api_key, status: ApiKey::STATUS_DISABLED)
    admin = create(:admin, password: TEST_PASSWORD)
    login_as admin
    get admin_api_keys_path
    assert_response :success
  end

  it 'show loads' do
    api_key = create(:api_key)
    admin = create(:admin, password: TEST_PASSWORD)
    login_as admin
    get admin_api_key_path(api_key)
    assert_response :success
  end

  it 'edit loads' do
    api_key = create(:api_key)
    admin = create(:admin, password: TEST_PASSWORD)
    login_as admin
    get edit_admin_api_key_path(api_key)
    assert_response :success
  end
end
