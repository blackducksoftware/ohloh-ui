require 'test_helper'

class LicensePermissionRoleTest < ActiveSupport::TestCase
  describe 'attributes' do 
    it 'must have a license' do
      license = create(:license)
      lpr = create(:license_permission_role, license: license)
      lpr.license.must_equal license
    end
  end
end
