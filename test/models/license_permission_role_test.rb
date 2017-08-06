require 'test_helper'

class LicensePermissionRoleTest < ActiveSupport::TestCase
  describe 'attributes' do 
    it 'must have a license' do
      license = create(:license)
      lpr = create(:license_permission_role, license: license)
      lpr.license.must_equal license
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
