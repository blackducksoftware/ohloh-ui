require 'test_helper'
require 'test_helpers/admin_test_helper'

class LicensePermissionRoleIntegrationTest < ActionDispatch::IntegrationTest
  include AdminTestHelper

  it 'shows the index page' do
    create_list(:license_permission_role, 2)
    create_and_login_admin

    get admin_license_permission_roles_path

    assert_response :success
  end
end
