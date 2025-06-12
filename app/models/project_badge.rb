# frozen_string_literal: true

class ProjectBadge < ApplicationRecord
  belongs_to :enlistment, optional: true
  delegate :project, :code_location, to: :enlistment

  validates :type, :identifier, presence: true
  validates :enlistment_id, presence: true,
                            uniqueness: { scope: [:type],
                                          message: I18n.t('.project_badges.repo_validation') }
  enum status: %i[inactive active]

  SUMMARY_LIMIT = 2

  class << self
    def check_cii_projects_last_run
      last_run = Setting.get_value('check_cii_projects')
      I18n.t('.no_data') if last_run.nil?
    end
  end
end
