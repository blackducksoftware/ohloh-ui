# frozen_string_literal: true

class LicensePermission < ApplicationRecord
  belongs_to :license_right, optional: true
  has_one :license_license_permission
  delegate :name, :icon, to: :license_right
  delegate :license, to: :license_license_permission
  validates :license_right_id, presence: true

  enum status: %i[Permitted Forbidden Required]
end
