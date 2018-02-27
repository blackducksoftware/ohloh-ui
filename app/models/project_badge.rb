class ProjectBadge < ActiveRecord::Base
  belongs_to :enlistment
  delegate :project, :code_location, to: :enlistment

  validates :type, :identifier, presence: true
  validates :enlistment_id, presence: true,
                            uniqueness: { scope: [:type],
                                          message: I18n.t('.project_badges.repo_validation') }
  enum status: [:inactive, :active]

  SUMMARY_LIMIT = 2

  class << self
    def check_cii_projects_last_run
      last_run = Setting.get_value('check_cii_projects')
      return I18n.t('.no_data') if last_run.nil?
    end
  end
end
