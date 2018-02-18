require 'test_helper'
require 'test_helpers/admin_test_helper'

class ActiveAdminTest < ActionDispatch::IntegrationTest
  include AdminTestHelper

  it 'allows admins in' do
    create(:load_average)
    create_and_login_admin
    get admin_root_path
    assert_response :ok
  end

  it 'disallows regular users' do
    login_as create(:account)
    get admin_root_path
    must_respond_with :unauthorized
  end

  it 'disallows unlogged users' do
    login_as nil
    get admin_root_path
    must_respond_with :unauthorized
  end
end
