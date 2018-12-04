class StackIgnore < ActiveRecord::Base
  belongs_to :stack
  belongs_to :project

  scope :for_project, ->(project) { where(project_id: project.id) }

  validates :stack, presence: true
  validates :project, presence: true

  after_create :clean_up_entries

  private

  def clean_up_entries
    stack.stack_entries.for_project_id(project.id).destroy_all
  end
end
