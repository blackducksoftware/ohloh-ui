require 'test_helper'

class ApiKeyAdminTest < ActionDispatch::IntegrationTest
  it 'index loads' do
    create(:api_key, status: ApiKey::STATUS_OK)
    create(:api_key, status: ApiKey::STATUS_LIMIT_EXCEEDED)
    create(:api_key, status: ApiKey::STATUS_DISABLED)
    login_as create(:admin)
    get admin_api_keys_path
    assert_response :success
  end

  it 'show loads' do
    api_key = create(:api_key)
    login_as create(:admin)
    get admin_api_key_path(api_key)
    assert_response :success
  end

  it 'edit loads' do
    api_key = create(:api_key)
    login_as create(:admin)
    get edit_admin_api_key_path(api_key)
    assert_response :success
  end
end
