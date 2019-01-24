class LicensePermissionRole < ActiveRecord::Base
  belongs_to :license
  belongs_to :license_permission_status
  validates :license_id, :license_permission_status_id, presence: true
  validates :license_permission_status_id, uniqueness: { scope: :license_id }

  delegate :status, to: :license_permission_status
end
