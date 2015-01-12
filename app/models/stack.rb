class Stack < ActiveRecord::Base
  belongs_to :account
  has_many :stack_entries, -> { where(deleted_at: nil) }, dependent: :destroy
  has_many :projects, -> { where.not(deleted: true) }, through: :stack_entries

  scope :has_account, -> { where.not(account_id: nil) }
end
