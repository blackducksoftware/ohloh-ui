require 'test_helper'

describe 'OhAdmin::LicensePermissionsController' do
  let(:admin) { create(:admin) }

  let(:license_permissions) { create(:license_permission, license_right: create(:license_right, name: 'Permitted')) }
  let(:license) { create(:license) }

  before do
    login_as admin
    license.license_license_permissions.create(license_permission_id: license_permissions.id)
  end

  it 'should return list of license_permissions' do
    get :index
    assigns(:license_permissions).first.must_equal license.license_license_permissions.first
  end

  it 'should filter the license_permissions correctly' do
    get :index, status: 2
    assigns(:license_permissions).count.must_equal 0
    get :index, license_id: license.id
    assigns(:license_permissions).count.must_equal 1
    get :index, commit: 'Clear Filter'
    assigns(:license_permissions).first.must_equal license.license_license_permissions.first
  end

  it 'unlogged users should respond with 401' do
    login_as nil
    get :index
    must_respond_with :unauthorized
  end
end
