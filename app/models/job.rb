class Job < ActiveRecord::Base
  STATUS_SCHEDULED = 0
  STATUS_RUNNING   = 1
  STATUS_FAILED    = 3
  STATUS_COMPLETED = 5

  scope :incomplete, -> { where.not(status: STATUS_COMPLETED) }

  belongs_to :project
  belongs_to :repository
  belongs_to :code_set
  belongs_to :sloc_set
  belongs_to :account
  belongs_to :organization

  class << self
    def incomplete_project_job(project_ids)
      where(project_id: project_ids).where.not(status: STATUS_COMPLETED).first
    end
  end
end
