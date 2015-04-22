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

  it '#short_name returns abbreviation if present' do
    create(:license, nice_name: 'Foobar', abbreviation: 'Foo').short_name.must_equal 'Foo'
  end

  it '#short_name returns nice_name if no abbreviation is available' do
    create(:license, nice_name: 'Foobar', abbreviation: nil).short_name.must_equal 'Foobar'
  end

  it '#autocomplete returns correct licenses' do
    license_1 = create(:license, nice_name: 'AutocompleteMIT')
    create(:license, nice_name: 'AutocompleteBSD')
    license_3 = create(:license, nice_name: 'AutocompleteMit v2')
    License.autocomplete('autocompletemit').map(&:id).sort.must_equal [license_1.id, license_3.id].sort
  end

  describe 'from_param' do
    it 'should match by name' do
      license = create(:license)
      License.from_param(license.name).first.id.must_equal license.id
    end
  end
end
