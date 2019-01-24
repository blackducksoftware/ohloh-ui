require 'test_helper'

class LicensePermissionRoleTest < ActiveSupport::TestCase
  describe 'attributes' do
    it 'must have a license and license_permission_status' do
      license = create(:license)
      permission = create(:license_permission, name: 'permitted')
      status = create(:license_permission_status, status: 'permitted',
                                                  license_permission_id: permission.id)
      lpr = create(:license_permission_role, license_permission_status: status, license: license)
      lpr.license.blank?.must_equal false
      lpr.license_permission_status.blank?.must_equal false
    end

    it 'must have a unique license permission for a license' do
      license = create(:license)
      permission = create(:license_permission, name: 'permitted')
      status = create(:license_permission_status, status: 'permitted',
                                                  license_permission_id: permission.id)

      create(:license_permission_role, license_permission_status: status, license: license)
      lpr2 = build(:license_permission_role, license_permission_status: status, license: license)
      lpr2.valid?.must_equal false
    end

    it 'is not valid if it does not have a license permission or license' do
      lpr = build(:license_permission_role, license_permission_status: nil, license: nil)
      lpr.valid?.must_equal false
    end

    it 'must be one of the valid states' do
      permitted_permission = create(:license_permission, name: 'permitted')
      forbidden_permission = create(:license_permission, name: 'forbidden')
      required_permission = create(:license_permission, name: 'required')
      lp = create(:license_permission_role, license_permission_status:
           create(:license_permission_status, status: 'permitted',
                                              license_permission_id: permitted_permission.id))
      lp.must_be :valid?
      lp = create(:license_permission_role, license_permission_status:
        create(:license_permission_status, status: 'forbidden',
                                           license_permission_id: forbidden_permission.id))
      lp.must_be :valid?
      lp = create(:license_permission_role, license_permission_status:
        create(:license_permission_status, status: 'required',
                                           license_permission_id: required_permission.id))
      lp.must_be :valid?
    end
  end
end
