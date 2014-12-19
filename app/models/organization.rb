class Organization < ActiveRecord::Base
  has_one :permission, as: :target
  has_many :projects, -> { where {deleted.not_eq true} }
  has_many :accounts
  belongs_to :logo

  scope :active, -> { where {deleted.not_eq true} }
end
