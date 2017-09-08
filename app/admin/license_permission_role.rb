ActiveAdmin.register LicensePermissionRole do
  permit_params :status, :license_id, :license_permission_id
end
