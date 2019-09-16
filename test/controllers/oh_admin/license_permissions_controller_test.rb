# frozen_string_literal: true

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

  it 'calls license_permission create' do
    get :new
    assert_select 'h2', 'No License Permissions Found'
    must_respond_with :success
  end

  it 'calls license_permissions create with a license id' do
    get :new, license_id: license.id
    assert_select 'h2', false, 'No h2 is found'
    must_respond_with :success
  end

  it 'creates a new permission' do
    lp = LicensePermission.first
    right_id = ('right_' + lp.license_right_id.to_s).to_sym

    license_right = create(:license_right, name: 'New Right')
    create(:license_permission, license_right: license_right)
    new_right_id = ('right_' + license_right.id.to_s).to_sym

    assert_difference 'LicenseLicensePermission.count', 1 do
      post :create, :license_id => license.id,
                    new_right_id => 0, right_id => lp.status
    end
  end

  it 'deletes an existing permission' do
    assert_difference 'LicenseLicensePermission.count', -1 do
      post :create, license_id: license.id
    end
  end

  it 'updates an existing license_license_permission with new status' do
    lp = LicensePermission.first
    right_id = ('right_' + lp.license_right_id.to_s).to_sym

    # // create another permission for forbidden permission
    new_lp = create(:license_permission, license_right_id: lp.license_right_id,
                                         status: LicensePermission.statuses['Forbidden'])

    assert LicenseLicensePermission.first.license_permission_id.must_equal lp.id
    post :create, :license_id => license.id,
                  right_id => LicensePermission.statuses['Forbidden']
    assert LicenseLicensePermission.first.license_permission_id.must_equal new_lp.id
  end
end
