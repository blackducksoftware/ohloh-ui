FactoryBot.define do
  factory :license_permission do |f|
    f.association :license_right
    license_right_id 0
    description 'MyString'
    status LicensePermission.statuses['permitted']
  end
end
