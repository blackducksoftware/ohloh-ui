# frozen_string_literal: true

module OrganizationJobs
  extend ActiveSupport::Concern

  def ensure_job(priority = 0)
    Job.transaction do
      return if jobs.incomplete.any?

      OrganizationJob.create(organization: self, priority: priority, wait_until: Time.current.utc + 1.day)
    end
  end

  def schedule_analysis(delay = 30.minutes)
    job = project_job = nil
    Job.transaction do
      project_job = Job.incomplete_project_job(projects.map(&:id))
      job = jobs.incomplete.first || project_job
      create_update_job(job, delay)
    end
  end

  def create_update_job(job, delay)
    if job.nil?
      job = OrganizationJob.create(organization: self, wait_until: Time.current.utc + delay)
    elsif job.is_a? OrganizationJob
      job.update_attribute(:wait_until, Time.current.utc + delay)
    end
    job
  end
end
