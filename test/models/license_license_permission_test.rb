# frozen_string_literal: true

require 'test_helper'

class LicenseLicensePermissionTest < ActiveSupport::TestCase
  describe 'attributes' do
    it 'must have a license and license_permission_id' do
      license = create(:license)
      create(:license_license_permission,
             license: license,
             license_permission: create(:license_permission,
                                        license_right: create(:license_right, name: 'permitted')))
      _(license.license_license_permissions.count).must_equal 1
      _(license.license_license_permissions.first.license.blank?).must_equal false
    end

    it 'is not valid if it does not have a license permission or license' do
      lpr = build(:license_license_permission, license_permission: nil, license: nil)
      _(lpr.valid?).must_equal false
    end
  end
end
