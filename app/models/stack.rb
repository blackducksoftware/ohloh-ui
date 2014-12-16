class Stack < ActiveRecord::Base
  has_many :stack_entries, -> { where(deleted_at: nil) }, dependent: :destroy

  scope :has_account, -> { where.not(account_id: nil) }
end
