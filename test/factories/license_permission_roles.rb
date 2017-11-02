FactoryBot.define do
  factory :license_permission_role do |f|
    f.association :license
    f.association :license_permission
    status 'permitted'

    factory :permitted_license_permission do
      status LicensePermissionRole.statuses['permitted']
    end

    factory :forbidden_license_permission do
      status LicensePermissionRole.statuses['forbidden']
    end

    factory :required_license_permission do
      status LicensePermissionRole.statuses['required']
    end
  end
end
