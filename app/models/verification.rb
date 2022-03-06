# frozen_string_literal: true

class Verification < ApplicationRecord
  belongs_to :account, optional: true

  validates :unique_id, :type, presence: true
  validates :unique_id, uniqueness: { scope: :type }
end
