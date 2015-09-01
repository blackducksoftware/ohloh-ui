class Slave::JobPicker
  CANDIDATE_LOCK_KEY = 100
  REPO_JOBS_LOCK_KEY = 200

  def initialize
    @slave = Slave.local
    @allowed_types = Job::BlockedType.new.allowed
  end

  def execute
    return unless @slave.allowed?
    return @slave.logs.create!(message: I18n.t('slaves.jobs_blocked'), level: SlaveLog::DEBUG) if @allowed_types.empty?

    job = scheduled_job
    return job if job || !@allowed_types.include?(CompleteJob)

    create_new_repository_jobs
    scheduled_job
  end

  private

  def scheduled_job
    loop do
      job = job_candidate
      return unless job
      job.update(slave_id: @slave.id, status: Job::STATUS_RUNNING)
      return job
    end
  end

  def job_candidate
    Job.with_advisory_lock(CANDIDATE_LOCK_KEY) do
      Job.scheduled
        .where('jobs.slave_id IS NULL OR jobs.slave_id = ?', @slave.id)
        .where("COALESCE(wait_until, '1980-01-01') <= now() at time zone 'utc'")
        .where(type: @allowed_types)
        .order(priority: :desc).order('slave_id IS NULL')
        .first
    end
  end

  def create_new_repository_jobs
    Job.with_advisory_lock(REPO_JOBS_LOCK_KEY) do
      Clump.oldest_fetchable(ENV['SCHEDULABLE_CLUMPS_LIMIT']).each(&:create_new_repository_jobs)
    end
  end
end
