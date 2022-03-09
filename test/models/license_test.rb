# frozen_string_literal: true

require 'test_helper'

class LicenseTest < ActiveSupport::TestCase
  it '#allow_edit? returns false for unlogged users by default' do
    license = create(:license)
    license.editor_account = nil
    _(license.allow_edit?).must_be_nil
  end

  it '#allow_edit? returns false for unlogged users while locked' do
    license = create(:license, locked: true)
    license.editor_account = nil
    _(license.allow_edit?).must_be_nil
  end

  it '#allow_edit? returns false for normal users while locked' do
    license = create(:license, locked: true)
    license.editor_account = create(:account)
    _(license.allow_edit?).must_equal false
  end

  it '#allow_edit? returns true for normal users while unlocked' do
    license = create(:license)
    license.editor_account = create(:account)
    _(license.allow_edit?).must_equal true
  end

  it '#allow_edit? returns true for admin users while locked' do
    license = create(:license, locked: true)
    license.editor_account = create(:admin)
    _(license.allow_edit?).must_equal true
  end

  it '#allow_edit? returns true for admin users while unlocked' do
    license = create(:license)
    license.editor_account = create(:admin)
    _(license.allow_edit?).must_equal true
  end

  it '#short_name returns vanity_url if present' do
    _(create(:license, name: 'Foobar', vanity_url: 'Foo').short_name).must_equal 'Foo'
  end

  describe 'autocomplete' do
    it 'must return correct licenses' do
      license1 = create(:license, name: 'AutocompleteMIT')
      create(:license, name: 'AutocompleteBSD')
      license3 = create(:license, name: 'AutocompleteMit v2')
      _(License.autocomplete('autocompletemit').map(&:id).sort).must_equal [license1.id, license3.id].sort
    end

    it 'must avoid deleted licenses' do
      license = create(:license)
      license.destroy
      _(License.autocomplete(license.name)).must_be :empty?
    end
  end

  describe 'from_param' do
    it 'should match by vanity_url' do
      license = create(:license)
      _(License.from_param(license.vanity_url).first.id).must_equal license.id
    end
  end

  describe 'vanity_url' do
    it 'should validate uniqueness' do
      license1 = create(:license)
      license2 = build(:license, vanity_url: license1.vanity_url)
      _(license2.valid?).must_equal false
      _(license2.errors.count).must_equal 2
      _(license2.errors[:vanity_url]).must_equal ['has already been taken']
    end

    it 'should validate length' do
      license = build(:license, vanity_url: 'a')
      _(license.valid?).must_equal false
      _(license.errors.count).must_equal 2
      _(license.errors[:vanity_url]).must_equal ['is too short (minimum is 2 characters)']
    end

    it 'must allow valid characters' do
      valid_vanity_urls = %w[license-name license_name licenseé license_]

      valid_vanity_urls.each do |vanity_url|
        license = build(:license, vanity_url: vanity_url)
        _(license).wont_be :valid?
      end
    end

    it 'wont allow invalid characters' do
      invalid_vanity_urls = %w[license.name .license -license _license]

      invalid_vanity_urls.each do |vanity_url|
        license = build(:license, vanity_url: vanity_url)
        _(license).wont_be :valid?
      end
    end
  end

  describe 'name' do
    let(:account) { create(:account) }

    it 'should validate uniqueness' do
      license1 = create(:license)
      license = build(:license, name: license1.name)
      _(license.valid?).must_equal false
      _(license.errors.count).must_equal 2
      _(license.errors[:name]).must_equal ['has already been taken']
    end

    it 'should validate length' do
      license = build(:license, name: '')
      _(license.valid?).must_equal false
      _(license.errors.count).must_equal 2
      _(license.errors[:name]).must_equal ['is too short (minimum is 1 character)']
    end

    it 'must validate name format' do
      license = build(:license, name: ';rm -rf /', editor_account: account)
      _(license.valid?).must_equal false
      _(license.errors.count).must_equal 1
      _(license.errors[:name]).must_equal [I18n.t('activerecord.errors.models.license.attributes.name.invalid')]
    end
  end

  describe 'description' do
    it 'should validate length' do
      license = build(:license, description: Faker::Lorem.characters(number: 50_001))
      _(license.valid?).must_equal false
      _(license.errors.count).must_equal 2
      _(license.errors[:description]).must_equal ['is too long (maximum is 50000 characters)']
    end
  end

  describe 'url' do
    it 'should validate url' do
      license = build(:license, url: 'invalid url')
      _(license.valid?).must_equal false
      _(license.errors.count).must_equal 2
      _(license.errors[:url]).must_equal ['Invalid URL Format']
    end
  end

  describe 'license deleted' do
    it 'when license is deleted the associated project license should be (soft) deleted' do
      license = create(:license)
      project = create(:project)
      account = create(:account)
      create(:project_license, project: project, license: license)
      license.editor_account = account
      _(project.project_licenses.count).must_equal 1
      project_license = project.project_licenses.first
      license.edits.first.undo!(account) # Undo the CreateEdit i.e. Removing the Licence
      _(license.reload.deleted?).must_equal true
      _(project.project_licenses.count).must_equal 0
      _(project_license.edits.first.allow_redo?).must_equal false # shouldn't allow Redo(License is deleted)
      # Redoing the License should redo the project license as well
      license.edits.first.redo!(account)
      _(license.reload.deleted?).must_equal false
      _(project.project_licenses.count).must_equal 1
      _(project_license.edits.first.allow_undo?).must_equal true
    end
  end

  describe 'license permissions' do
    it 'can have a set of license permissions' do
      _(create(:license)).must_respond_to(:license_permissions)
    end

    it 'can have required license_permissions' do
      license = create(:license)
      permission = create(:license_permission)
      create(:license_license_permission,  license_permission_id: permission.id,
                                           license_id: license.id)

      _(license.license_permissions.count).must_equal 1
      _(license.license_permissions.first).must_equal permission
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

        _(l.license_permissions.count).must_equal 3
        _(l.permitted_license_permissions.count).must_equal 1
        _(l.forbidden_license_permissions.count).must_equal 1
        _(l.required_license_permissions.count).must_equal 1
      end
    end
  end
end
