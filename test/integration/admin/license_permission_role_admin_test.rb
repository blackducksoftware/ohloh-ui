require 'test_helper'

class LicensePermissionRoleAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }
  let(:license_permission) { create(:license_permission) }

  before do
    login_as admin
  end

  it 'load the index page' do
    get admin_license_permission_roles_path
    assert_response :success
  end

  it 'should load the new page' do
    get new_admin_license_permission_role_path
    assert_response :success
  end

  it 'should be able to create a new license permission role with associated license and license permission' do
    license = create(:license)
    license_permission = create(:license_permission)
    assert_difference 'LicensePermissionRole.count' do
      post '/admin/license_permission_roles', license_permission_role: { status: 'required',
                                                                         license_id: license.id,
                                                                         license_permission_id: license_permission.id }
    end
  end

  it 'should load the show page' do
    license_permission_role = create(:license_permission_role)
    get admin_license_permission_role_path(license_permission_role)
    assert_response :success
  end

  it 'should load the edit page' do
    license_permission_role = create(:license_permission_role)
    get edit_admin_license_permission_role_path(license_permission_role)
    assert_response :success
  end

  it 'should be able to update a license permission role' do
    lpr = create(:license_permission_role)
    put "/admin/license_permission_roles/#{lpr.id}", license_permission_role: { license_id: lpr.license_permission_id,
                                                                                license_permission_id: lpr.license_id,
                                                                                status: 'forbidden' }

    lpr.reload
    assert_not_equal 'permitted', lpr.status
    assert_equal 'forbidden', lpr.status
  end

  it 'should destroy a license permission role' do
    license_permission_role = create(:license_permission_role)
    assert_difference('LicensePermissionRole.count', -1) do
      delete admin_license_permission_role_path(license_permission_role)
    end
  end
end
