class LicensePermission < ActiveRecord::Base
  belongs_to :license_right
  has_one :license_license_permission
  delegate :name, :icon, to: :license_right
  delegate :license, to: :license_license_permission
  validates :license_right_id, presence: true

  enum status: %i[permitted forbidden required]
end
