class FailureGroup < ActiveRecord::Base
  has_many :jobs, -> { where(status: Job::STATUS_FAILED).with_exception }

  # rubocop:disable Rails/SkipsModelValidations # We want a quick DB update in the following methods.
  def decategorize
    jobs.update_all(failure_group_id: nil)
  end

  class << self
    def recategorize
      categorized_failed_jobs.update_all(failure_group_id: nil)
      categorize
    end

    def categorize
      FailureGroup.order(priority: :desc, name: :asc).each do |failure_group|
        get_failed_jobs_by_exceptions(failure_group).update_all(failure_group_id: failure_group.id)
      end
    end

    private

    def categorized_failed_jobs
      Job.failed.where.not(failure_group_id: nil)
    end

    def get_failed_jobs_by_exceptions(failure_group)
      Job.failed.where(failure_group_id: nil).where('exception ILIKE ?', failure_group.pattern)
    end
  end
  # rubocop:enable Rails/SkipsModelValidations
end
