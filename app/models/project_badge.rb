class ProjectBadge < ActiveRecord::Base
  belongs_to :project
  belongs_to :repository

  validates :url, presence: true
  validates :repository_id, presence: true, uniqueness: { scope: :project_id }
end
