class Manage < ActiveRecord::Base
  belongs_to :account
  belongs_to :target, polymorphic: true

  scope :for_project, ->(project) { where(target_type: 'Project', target_id: project.id) }
  scope :active, -> { where.not(approved_by: nil) }
end
