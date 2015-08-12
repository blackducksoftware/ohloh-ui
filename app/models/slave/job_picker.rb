class Slave::JobPicker
  DEFAULT_JOB_PRIORITY = -10

  def initialize
    @slave = Slave.local
    @allowed_types = Job::BlockedType.new.allowed
  end

  def execute
    return unless @slave.allowed?
    return @slave.logs.create!(message: I18n.t('slaves.jobs_blocked'), level: SlaveLog::DEBUG) if @allowed_types.empty?

    job = scheduled_job
    return job if job || !@allowed_types.include?(CompleteJob)

    schedule_fetch
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
    Job.scheduled
      .where('jobs.slave_id IS NULL OR jobs.slave_id = ?', @slave.id)
      .where("COALESCE(wait_until, '1980-01-01') <= now() at time zone 'utc'")
      .where(type: @allowed_types)
      .order(priority: :desc).order('slave_id IS NULL')
      .first
  end

  def schedule_fetch
    clumps = Clump.oldest_fetchable(ENV['SCHEDULABLE_CLUMPS_LIMIT'])
    clumps.each { |clump| schedule_repository_fetch(clump) }
  end

  def schedule_repository_fetch(clump)
    clump.code_set.repository.enlistments.map(&:project).each do |project|
      project.repositories.each { |r| r.schedule_fetch(DEFAULT_JOB_PRIORITY) }
      @slave.logs.create!(message: I18n.t('slaves.auto_scheduled_fetch', id: project.id, name: project.name))
    end
  end
end
