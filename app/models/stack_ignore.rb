# frozen_string_literal: true

class StackIgnore < ApplicationRecord
  belongs_to :stack, optional: true
  belongs_to :project, optional: true

  scope :for_project, ->(project) { where(project_id: project.id) }

  validates :stack, presence: true
  validates :project, presence: true

  after_create :clean_up_entries

  private

  def clean_up_entries
    stack.stack_entries.for_project_id(project.id).destroy_all
  end
end
