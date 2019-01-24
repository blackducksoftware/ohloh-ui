class LicensePermissionStatus < ActiveRecord::Base
  has_one :license_permission
  has_many :license_permission_roles
  enum status: %i[permitted forbidden required]
end
