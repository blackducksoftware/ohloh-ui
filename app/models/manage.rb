class Manage < ActiveRecord::Base
  scope :for_project, ->(project) { where(target_type: 'Project', target_id: project.id) }
  scope :active, -> { where.not(approved_by: nil) }
end
