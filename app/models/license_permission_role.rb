class LicensePermissionRole < ActiveRecord::Base
  belongs_to :license
  belongs_to :license_permission
  validates :license_id, :license_permission_id, presence: true
  validates :license_permission_id, uniqueness: { scope: :license_id }

  enum status: %i[permitted forbidden required]
end
