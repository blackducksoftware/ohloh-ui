module CodeLocationJobs
  extend ActiveSupport::Concern

  included do
    def ensure_job(priority = 0)
      job = nil
      Job.transaction do
        job = jobs.incomplete.first
        return job if job
        # NOTE: PDP 2018-02-01 This method doesn't schedule a Fetch or Complete if the CL
        # hasn't been updated recently.  It should create a CompleteJob if there isn't one scheduled
        # However, it creates a FetchJob only if there is no best_code_set. How does this ensure a CL is updated?
        job = create_fetch_job(priority) unless best_code_set_id
        job = create_import_or_sloc_jobs(priority) if best_code_set_id
      end
      job
    end

    def schedule_fetch
      return ensure_job unless best_code_set
      create_complete_job
    end

    def remove_pending_jobs
      jobs.scheduled.each(&:destroy)
      jobs.failed.each(&:destroy)
    end

    def jobs
      Job.where(code_location_id: @id)
    end

    private

    def create_complete_job
      return if any_incomplete_or_recent?
      create_job(CompleteJob, code_location_id: @id, code_set_id: best_code_set_id)
    end

    def any_incomplete_or_recent?
      jobs = best_code_set.jobs.incomplete_or_since(Time.current - 5.minutes)
      # Filter out TarballJobs
      jobs = jobs.to_a.delete_if { |j| j.type == 'TarballJob' }
      jobs.present?
    end

    def create_fetch_job(priority)
      cs = CodeSet.create(code_location_id: @id)
      FetchJob.create(code_set: cs, priority: priority)
    end

    def create_import_or_sloc_jobs(priority)
      sloc_set = best_code_set.best_sloc_set
      if sloc_set.blank?
        create_job(ImportJob, code_set: best_code_set, priority: priority)
      elsif sloc_set.as_of.to_i < best_code_set.as_of.to_i
        create_job(SlocJob, sloc_set: sloc_set, priority: priority)
      end
    end

    def create_job(job_class, **params)
      update_do_not_fetch if do_not_fetch
      job_class.create!(params)
    end

    def update_do_not_fetch
      update(do_not_fetch: false)
    end
  end
end
