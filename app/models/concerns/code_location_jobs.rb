module CodeLocationJobs
  extend ActiveSupport::Concern

  included do
    def ensure_job(priority = 0)
      job = nil
      Job.transaction do
        job = jobs.incomplete.first
        return job if job
        job = create_fetch_job(priority) if best_code_set.blank?
        job = create_import_or_sloc_jobs(priority) if best_code_set.present?
      end
      job
    end

    def schedule_fetch
      return ensure_job unless best_code_set

      return if best_code_set.jobs.incomplete_or_since(Time.current - 5.minutes).present?

      CompleteJob.create!(code_location_id: best_code_set.code_location_id, code_set_id: best_code_set.id)
    end

    def refetch
      remove_pending_jobs
      create_repository_directory
      FetchJob.create!(code_set: CodeSet.create!(code_location: self))
    end

    def remove_pending_jobs
      jobs.scheduled.each(&:destroy)
      jobs.failed.each(&:destroy)
    end

    private

    def create_repository_directory
      object = parent_repository_directory
      repository_directory = object.repository_directories.create!
      object.update(best_repository_directory_id: repository_directory.id)
    end

    def create_fetch_job(priority)
      cs = CodeSet.create(code_location: self)
      FetchJob.create(code_set: cs, priority: priority)
    end

    def create_import_or_sloc_jobs(priority)
      sloc_set = best_code_set.best_sloc_set
      if sloc_set.blank?
        ImportJob.create(code_set: best_code_set, priority: priority)
      elsif sloc_set.as_of.to_i < best_code_set.as_of.to_i
        SlocJob.create(sloc_set: sloc_set, priority: priority)
      end
    end
  end
end
