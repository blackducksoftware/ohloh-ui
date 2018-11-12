desc 'Remove duplicate Microsoft Public License records'
task remove_duplicate_microsoft_public_license: :environment do
  ProjectLicense.where(license_id: 357).update_all(license_id: 150)
  LicensePermissionRole.where(license_id: 357).destroy_all
  ActiveRecord::Base.connection.execute('delete from licenses where id=357;')
  Edit.where(target_type: 'License', target_id: '357').destroy_all

  license = License.find(150)
  license.editor_account = Account.hamster
  license.update(vanity_url: 'Microsoft_Public_License')
end
