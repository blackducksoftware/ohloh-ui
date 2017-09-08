class LicensePermission < ActiveRecord::Base
  has_many :license_permission_roles
  has_many :licenses, through: :license_permission_roles, dependent: :destroy
end
