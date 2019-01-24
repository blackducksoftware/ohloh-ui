class LicensePermission < ActiveRecord::Base
  has_many :license_permission_roles, through: :license_permission_statuses
  # has_many :licenses, through: :license_permission_statuses, dependent: :destroy
end
