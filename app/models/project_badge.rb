class ProjectBadge < ActiveRecord::Base
  belongs_to :project
  belongs_to :repository

  validates :identifier, presence: true
  validates :repository_id, presence: true, uniqueness: { scope: [:project_id, :type], message: "Repository already has the selected badge" }
  enum status: [:inactive, :active]
end
