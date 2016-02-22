class FailureGroup < ActiveRecord::Base
  has_many :jobs, -> { where(status: Job::STATUS_FAILED) }

  def decategorize
    jobs.update_all(failure_group_id: nil)
  end

  class << self
    def recategorize(job_id: nil)
      categorized_failed_jobs(job_id).update_all(failure_group_id: nil)
      categorize
    end

    def categorize(job_id: nil)
      FailureGroup.order(priority: :desc, name: :asc).each do |failure_group|
        get_failed_jobs_by_exceptions(failure_group, job_id).update_all(failure_group_id: failure_group.id)
      end
    end

    private

    def categorized_failed_jobs(job_id)
      jobs = Job.failed.where.not(failure_group_id: nil)
      job_id ? jobs.where(id: job_id) : jobs.where(nil)
    end

    def get_failed_jobs_by_exceptions(failure_group, job_id)
      jobs = Job.failed.where(failure_group_id: nil).where('exception ILIKE ?', failure_group.pattern)
      job_id ? jobs.where(id: job_id) : jobs.where(nil)
    end
  end
end
