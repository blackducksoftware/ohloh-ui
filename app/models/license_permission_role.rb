class LicensePermissionRole < ActiveRecord::Base
  belongs_to :license
  belongs_to :license_permission
end
