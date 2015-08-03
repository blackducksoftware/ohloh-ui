class FailureGroup < ActiveRecord::Base
  has_many :jobs, -> { where(status: Job::STATUS_FAILED) }

  validates_presence_of :name, :pattern

  class << self
    def categorize(job_id)
      job = Job.failed.where(id: job_id).where.not(failure_group_id: nil).first
      job.update(failure_group_id: nil)

      order(priority: :desc, name: :asc, id: :asc).each do |failure_group|
        failure_group.jobs.where(id: job_id, failure_group_id: nil)
          .where(Job.arel_table[:exception].matches(failure_group.pattern))
      end
    end
  end

end
