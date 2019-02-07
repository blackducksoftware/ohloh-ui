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
end
