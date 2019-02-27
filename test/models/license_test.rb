require 'test_helper'

class LicenseTest < ActiveSupport::TestCase
  it '#allow_edit? returns false for unlogged users by default' do
    license = create(:license)
    license.editor_account = nil
    assert_nil license.allow_edit?
  end

  it '#allow_edit? returns false for unlogged users while locked' do
    license = create(:license, locked: true)
    license.editor_account = nil
    assert_nil license.allow_edit?
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

  it '#short_name returns vanity_url if present' do
    create(:license, name: 'Foobar', vanity_url: 'Foo').short_name.must_equal 'Foo'
  end

  describe 'autocomplete' do
    it 'must return correct licenses' do
      license1 = create(:license, name: 'AutocompleteMIT')
      create(:license, name: 'AutocompleteBSD')
      license3 = create(:license, name: 'AutocompleteMit v2')
      License.autocomplete('autocompletemit').map(&:id).sort.must_equal [license1.id, license3.id].sort
    end

    it 'must avoid deleted licenses' do
      license = create(:license)
      license.destroy
      License.autocomplete(license.name).must_be :empty?
    end
  end

  describe 'from_param' do
    it 'should match by vanity_url' do
      license = create(:license)
      License.from_param(license.vanity_url).first.id.must_equal license.id
    end
  end

  describe 'vanity_url' do
    it 'should validate uniqueness' do
      license1 = create(:license)
      license2 = build(:license, vanity_url: license1.vanity_url)
      license2.valid?.must_equal false
      license2.errors.count.must_equal 2
      license2.errors[:vanity_url].must_equal ['has already been taken']
    end

    it 'should validate length' do
      license = build(:license, vanity_url: 'a')
      license.valid?.must_equal false
      license.errors.count.must_equal 2
      license.errors[:vanity_url].must_equal ['is too short (minimum is 2 characters)']
    end

    it 'must allow valid characters' do
      valid_vanity_urls = %w[license-name license_name licenseé license_]

      valid_vanity_urls.each do |vanity_url|
        license = build(:license, vanity_url: vanity_url)
        license.wont_be :valid?
      end
    end

    it 'wont allow invalid characters' do
      invalid_vanity_urls = %w[license.name .license -license _license]

      invalid_vanity_urls.each do |vanity_url|
        license = build(:license, vanity_url: vanity_url)
        license.wont_be :valid?
      end
    end
  end

  describe 'name' do
    it 'should validate uniqueness' do
      license1 = create(:license)
      license = build(:license, name: license1.name)
      license.valid?.must_equal false
      license.errors.count.must_equal 2
      license.errors[:name].must_equal ['has already been taken']
    end

    it 'should validate length' do
      license = build(:license, name: '')
      license.valid?.must_equal false
      license.errors.count.must_equal 2
      license.errors[:name].must_equal ['is too short (minimum is 1 character)']
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

  describe 'license deleted' do
    it 'when license is deleted the associated project license should be (soft) deleted' do
      license = create(:license)
      project = create(:project)
      account = create(:account)
      create(:project_license, project: project, license: license)
      license.editor_account = account
      project.project_licenses.count.must_equal 1
      project_license = project.project_licenses.first
      license.edits.first.undo!(account) # Undo the CreateEdit i.e. Removing the Licence
      license.reload.deleted?.must_equal true
      project.project_licenses.count.must_equal 0
      project_license.edits.first.allow_redo?.must_equal false # ProjectLicense shouldn't allow Redo(License is deleted)
      # Redoing the License should redo the project license as well
      license.edits.first.redo!(account)
      license.reload.deleted?.must_equal false
      project.project_licenses.count.must_equal 1
      project_license.edits.first.allow_undo?.must_equal true
    end
  end

  describe 'license permissions' do
    it 'can have a set of license permissions' do
      create(:license).must_respond_to(:license_permissions)
    end

    it 'can have required license_permissions' do
      license = create(:license)
      permission = create(:license_permission)
      create(:license_license_permission,  license_permission_id: permission.id,
                                           license_id: license.id)

      license.license_permissions.count.must_equal 1
      license.license_permissions.first.must_equal permission
    end

    it 'will get the correct license_permissions' do
      permitted_permission = create(:license_permission, license_right: create(:license_right, name: 'Permitted'))
      forbidden_permission = create(:license_permission, status: LicensePermission.statuses['Forbidden'],
                                                         license_right: create(:license_right, name: 'Forbidden'))
      required_permission = create(:license_permission, status: LicensePermission.statuses['Required'],
                                                        license_right: create(:license_right, name: 'Required'))

      create(:license) do |l|
        # Add a Permitted permission
        l.license_license_permissions.create(license_permission_id: permitted_permission.id)

        # Add a Forbidden permission
        l.license_license_permissions.create(license_permission_id: forbidden_permission.id)

        # Add a Required permission
        l.license_license_permissions.create(license_permission_id: required_permission.id)

        l.license_permissions.count.must_equal 3
        l.permitted_license_permissions.count.must_equal 1
        l.forbidden_license_permissions.count.must_equal 1
        l.required_license_permissions.count.must_equal 1
      end
    end
  end
end
