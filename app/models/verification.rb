class Verification < ActiveRecord::Base
  belongs_to :account

  validates :auth_id, :type, presence: true
  validates :auth_id, uniqueness: true
end
