FactoryBot.define do
  factory :license_permission_status do |f|
    f.association :license_permission
    license_permission_id 0
    description 'MyString'
    status LicensePermissionStatus.statuses['permitted']
  end
end
