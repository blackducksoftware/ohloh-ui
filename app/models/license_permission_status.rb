class LicensePermissionStatus < ActiveRecord::Base
  belongs_to :license_permission
  has_many :license_permission_roles
  enum status: %i[permitted forbidden required]
end
