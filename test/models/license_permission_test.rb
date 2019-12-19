# frozen_string_literal: true

require 'test_helper'

class LicensePermissionTest < ActiveSupport::TestCase
  describe 'attributes' do
    it 'has a name, description, and icon' do
      lp = create(:license_permission)
      lp.must_respond_to(:name)
      lp.must_respond_to(:description)
      lp.must_respond_to(:icon)
    end
  end
end
