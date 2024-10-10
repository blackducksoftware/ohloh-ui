# frozen_string_literal: true

class Verification < ApplicationRecord
  belongs_to :account, optional: true

  validates :type, presence: true
end
