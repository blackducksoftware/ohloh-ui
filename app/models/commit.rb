class Commit < ActiveRecord::Base
  belongs_to :code_set
  belongs_to :name

  scope :for_project, lambda { |project|
    joins(code_set: { repository: { enlistments: :project } })
      .where(enlistments: { deleted: false })
      .where(projects: { id: project.id })
  }
end
