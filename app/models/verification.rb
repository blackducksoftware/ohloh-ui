# frozen_string_literal: true

class Verification < ActiveRecord::Base
  belongs_to :account

  validates :unique_id, :type, presence: true
  validates :unique_id, uniqueness: { scope: :type }
end
