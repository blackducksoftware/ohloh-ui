require 'test_helper'

class LicensePermissionAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }
  let(:license_permission) { create(:license_permission) }

  before do
    login_as admin
  end

  it 'load the index page' do
    get admin_license_permissions_path
    assert_response :success
  end

  it 'should load the new page' do
    get new_admin_license_permission_path
    assert_response :success
  end

  it 'should be able to create a new license permission' do
    assert_difference('LicensePermission.count', 1) do
      post '/admin/license_permissions', license_permission: { name: 'MyString',
                                                               description: 'MyString',
                                                               icon: 'MyString' }
    end
  end

  it 'should load the show page' do
    license_permission = create(:license_permission)
    get admin_license_permission_path(license_permission)
    assert_response :success
  end

  it 'should load the edit page' do
    license_permission = create(:license_permission)
    get edit_admin_license_permission_path(license_permission)
    assert_response :success
  end

  it 'should be able to update a license permission' do
    license_permission = create(:license_permission)
    put "/admin/license_permissions/#{license_permission.id}", license_permission: { id: license_permission.id,
                                                                                     name: 'MyString2',
                                                                                     description: 'MyString2',
                                                                                     icon: 'MyString2' }
    license_permission.reload
    assert_not_equal 'MyString', license_permission.name
    assert_not_equal 'MyString', license_permission.description
    assert_not_equal 'MyString', license_permission.icon
    assert_equal 'MyString2', license_permission.name
    assert_equal 'MyString2', license_permission.description
    assert_equal 'MyString2', license_permission.icon
  end

  it 'should destroy a license permission' do
    license_permission = create(:license_permission)
    assert_difference('LicensePermission.count', -1) do
      delete admin_license_permission_path(license_permission)
    end
  end
end
