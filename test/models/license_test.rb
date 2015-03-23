require 'test_helper'

class LicenseTest < ActiveSupport::TestCase
  it '#allow_edit? returns false for unlogged users by default' do
    license = create(:license)
    license.editor_account = nil
    license.allow_edit?.must_equal nil
  end

  it '#allow_edit? returns false for unlogged users while locked' do
    license = create(:license, locked: true)
    license.editor_account = nil
    license.allow_edit?.must_equal nil
  end

  it '#allow_edit? returns false for normal users while locked' do
    license = create(:license, locked: true)
    license.editor_account = create(:account)
    license.allow_edit?.must_equal false
  end

  it '#allow_edit? returns true for normal users while unlocked' do
    license = create(:license)
    license.editor_account = create(:account)
    license.allow_edit?.must_equal true
  end

  it '#allow_edit? returns true for admin users while locked' do
    license = create(:license, locked: true)
    license.editor_account = create(:admin)
    license.allow_edit?.must_equal true
  end

  it '#allow_edit? returns true for admin users while unlocked' do
    license = create(:license)
    license.editor_account = create(:admin)
    license.allow_edit?.must_equal true
  end

  it '#autocomplete returns correct licenses' do
    license_1 = create(:license, nice_name: 'AutocompleteMIT')
    create(:license, nice_name: 'AutocompleteBSD')
    license_3 = create(:license, nice_name: 'AutocompleteMit v2')
    License.autocomplete('autocompletemit').map(&:id).sort.must_equal [license_1.id, license_3.id].sort
  end
end
