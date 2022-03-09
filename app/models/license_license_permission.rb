# frozen_string_literal: true

class LicenseLicensePermission < ApplicationRecord
  belongs_to :license, optional: true
  belongs_to :license_permission, optional: true
  delegate :name, :icon, :status, to: :license_permission
  validates :license_permission, presence: true
  validates :license, presence: true
end
