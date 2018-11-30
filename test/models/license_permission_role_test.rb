require 'test_helper'

class LicensePermissionRoleTest < ActiveSupport::TestCase
  describe 'attributes' do
    it 'must have a license and license_permission' do
      lpr = create(:license_permission_role)
      lpr.license.blank?.must_equal false
      lpr.license_permission.blank?.must_equal false
    end

    it 'must have a unique license permission for a license' do
      license = create(:license)
      lp = create(:license_permission)
      create(:license_permission_role, license_permission: lp, license: license)
      lpr2 = build(:license_permission_role, license_permission: lp, license: license)
      lpr2.valid?.must_equal false
    end

    it 'is not valid if it does not have a license permission or license' do
      lpr = build(:license_permission_role, license_permission: nil, license: nil)
      lpr.valid?.must_equal false
    end

    it 'must be one of the valid states' do
      lp = create(:license_permission_role, status: 'permitted')
      lp.must_be :valid?
      lp = create(:license_permission_role, status: 'forbidden')
      lp.must_be :valid?
      lp = create(:license_permission_role, status: 'required')
      lp.must_be :valid?
    end

    it 'must not allow an invalid state' do
      proc { create(:license_permission_role, status: 'not_at_all_valid') }.must_raise ArgumentError
    end
  end
end
