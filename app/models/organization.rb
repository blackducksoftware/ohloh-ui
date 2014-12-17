class Organization < ActiveRecord::Base
  has_one :permission, as: :target
  belongs_to :logo
  has_many :manages, -> { where(deleted_at: nil, deleted_by: nil) }, as: 'target'
  has_many :managers, through: :manages, source: :account
end
