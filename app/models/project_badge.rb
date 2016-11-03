class ProjectBadge < ActiveRecord::Base
  belongs_to :project
  belongs_to :repository

  validates :identifier, presence: true
  validates :repository_id, presence: true,
                            uniqueness: { scope: [:project_id, :type],
                                          message: I18n.t('.project_badges.repo_validation') }
  enum status: [:inactive, :active]

  SUMMARY_LIMIT = 2

  class << self
    def check_cii_projects_last_run
      last_run = Setting.get_value('check_cii_projects')
      return I18n.t('.no_data') if last_run.nil?
      last_run.to_date.to_s(:mdy)
    end
  end
end
