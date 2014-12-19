class Stack < ActiveRecord::Base
	belongs_to :account
	has_many :stack_entries, -> { where {deleted_at.eq(nil)} }, dependent: :destroy
	has_many :projects, -> { where {deleted_at.not_eq(true)} }, through: :stack_entries
end
