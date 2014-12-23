class Stack < ActiveRecord::Base
  has_many :stack_entries, -> { where(deleted_at: nil) }, dependent: :destroy
  has_many :projects, -> { where(Project.arel_table[:deleted].eq(false)) }, through: :stack_entries
end
