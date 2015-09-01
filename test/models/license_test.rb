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

  describe 'name' do
    it 'should validate uniqueness' do
      license_1 = create(:license)
      license_2 = build(:license, name: license_1.name)
      license_2.valid?.must_equal false
      license_2.errors.count.must_equal 2
      license_2.errors[:name].must_equal ['has already been taken']
    end

    it 'should validate length' do
      license = build(:license, name: 'a')
      license.valid?.must_equal false
      license.errors.count.must_equal 2
      license.errors[:name].must_equal ['is too short (minimum is 2 characters)']
    end

    it 'must allow valid characters' do
      valid_names = %w(license-name license_name licenseé license_)

      valid_names.each do |name|
        license = build(:license, name: name)
        license.wont_be :valid?
      end
    end

    it 'wont allow invalid characters' do
      invalid_names = %w(license.name .license -license _license)

      invalid_names.each do |name|
        license = build(:license, name: name)
        license.wont_be :valid?
      end
    end
  end

  describe 'nice_name' do
    it 'should validate uniqueness' do
      license_1 = create(:license)
      license = build(:license, nice_name: license_1.nice_name)
      license.valid?.must_equal false
      license.errors.count.must_equal 2
      license.errors[:nice_name].must_equal ['has already been taken']
    end

    it 'should validate length' do
      license = build(:license, nice_name: '')
      license.valid?.must_equal false
      license.errors.count.must_equal 2
      license.errors[:nice_name].must_equal ['is too short (minimum is 1 character)']
    end
  end

  describe 'abbreviation' do
    it 'should validate length' do
      license = build(:license, abbreviation: Faker::Lorem.characters(102))
      license.valid?.must_equal false
      license.errors.count.must_equal 2
      license.errors[:abbreviation].must_equal ['is too long (maximum is 100 characters)']
    end

    it 'should allow nil' do
      license = build(:license, abbreviation: nil, editor_account: create(:account))
      license.valid?.must_equal true
    end
  end

  describe 'description' do
    it 'should validate length' do
      license = build(:license, description: Faker::Lorem.characters(50_001))
      license.valid?.must_equal false
      license.errors.count.must_equal 2
      license.errors[:description].must_equal ['is too long (maximum is 50000 characters)']
    end
  end

  describe 'url' do
    it 'should validate url' do
      license = build(:license, url: 'invalid url')
      license.valid?.must_equal false
      license.errors.count.must_equal 2
      license.errors[:url].must_equal ['Invalid URL Format']
    end
  end
end
