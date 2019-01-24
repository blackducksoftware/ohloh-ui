FactoryBot.define do
  factory :license_permission_role do
    license_id 0
    license_permission_status_id 0

    factory :permitted_license_permission do
      status LicensePermissionStatus.statuses['permitted']
    end

    factory :forbidden_license_permission do
      status LicensePermissionStatus.statuses['forbidden']
    end

    factory :required_license_permission do
      status LicensePermissionStatus.statuses['required']
    end
  end
end
