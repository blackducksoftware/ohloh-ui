class Job < ActiveRecord::Base
  STATUS_SCHEDULED = 0
  STATUS_RUNNING   = 1
  STATUS_FAILED    = 3
  STATUS_COMPLETED = 5

  scope :incomplete, -> { where.not(status: STATUS_COMPLETED) }

  belongs_to :organization

  class << self
    def incomplete_project_job(project_ids)
      where('status != ? AND project_id IN (?)', STATUS_COMPLETED,  project_ids).first
    end
  end
end
