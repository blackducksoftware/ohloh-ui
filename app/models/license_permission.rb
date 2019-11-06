# frozen_string_literal: true

# rubocop:disable HasManyOrHasOneDependent

class LicensePermission < ActiveRecord::Base
  belongs_to :license_right
  has_one :license_license_permission
  delegate :name, :icon, to: :license_right
  delegate :license, to: :license_license_permission
  validates :license_right_id, presence: true

  enum status: { 'Permitted': 0, 'Forbidden': 1, 'Required': 2 }
end

# rubocop:enable HasManyOrHasOneDependent
