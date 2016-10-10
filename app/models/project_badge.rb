class ProjectBadge < ActiveRecord::Base
  belongs_to :project
  belongs_to :repository

  validates :identifier, presence: true
  validates :repository_id, presence: true,
                            uniqueness: { scope: [:project_id, :type],
                                          message: I18n.t('.project_badges.repo_validation') }
  enum status: [:inactive, :active]
end
