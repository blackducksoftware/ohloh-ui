# frozen_string_literal: true

class LicenseLicensePermission < ActiveRecord::Base
  belongs_to :license
  belongs_to :license_permission
  delegate :name, :icon, :status, to: :license_permission
  validates :license_permission, presence: true
  validates :license, presence: true
end
