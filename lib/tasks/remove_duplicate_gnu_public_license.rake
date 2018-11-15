desc 'Remove duplicate GNU General Public License records'
task remove_duplicate_gnu_general_public_license: :environment do
  original_license = License.find(122) # GNU General Public License v3.0 only(gpl3)
  duplicate_license_ids = []

  duplicate_license_ids << License.find(523).id  # GNU Public License version 3(gpl_v3)
  duplicate_license_ids << License.find(479).id  # GNU General Public License v3.0(GPL-3)
  duplicate_license_ids << License.find(578).id  # GPL 3(GPL_3)
  duplicate_license_ids << License.find(301).id  # GNU GENERAL PUBLIC LICENSE(GPLv3)
  duplicate_license_ids << License.find(485).id  # GNU General Public License 3 or later(GPLv3plus)

  # Update project licenses
  ProjectLicense.where(license_id: duplicate_license_ids).update_all(license_id: original_license.id)

  # Delete license permission role mappings for the duplicate licenses
  LicensePermissionRole.where(license_id: duplicate_license_ids).destroy_all

  # Delete edits records of duplicate licenses
  Edit.where(target_type: 'License', target_id: duplicate_license_ids).destroy_all

  # Delete duplicate licenses
  ActiveRecord::Base.connection.execute("delete from licenses where id in (#{duplicate_license_ids.join(',')});")
end
