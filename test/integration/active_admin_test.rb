require 'test_helper'

class ActiveAdminTest < ActionDispatch::IntegrationTest
  it 'allows admins in' do
    admin = create(:admin, password: 'xyzzy123456')
    admin.password = 'xyzzy123456'
    create(:load_average)
    login_as admin
    get admin_root_path
    assert_response :success
  end

  it 'disallows regular users' do
    login_as create(:account)
    get admin_root_path
    assert_response :unauthorized
  end

  it 'disallows unlogged users' do
    login_as nil
    get admin_root_path
    assert_response :unauthorized
  end
end
