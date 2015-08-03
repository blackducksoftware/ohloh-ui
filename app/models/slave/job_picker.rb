class Slave::JobPicker
  DEFAULT_JOB_PRIORITY = -10
  CLUMPS_TO_SCHEDULE = 50

  delegate :id, :allowed?, :disk_full?, :oldest_fetchable_clumps, to: :@slave

  def initialize
    @slave = Slave.local
    @allowed_types = Job::BlockedType.new.allowed
  end

  def execute
    return unless allowed?
    return @slave.logs.create!(message: I18n.t('slaves.jobs_blocked'), level: SlaveLog::DEBUG) if @allowed_types.empty?

    job = scheduled_job
    return job if job || !@allowed_types.include?(CompleteJob)

    schedule_fetch
    scheduled_job
  end

  private

  def scheduled_job
    loop do
      candidate = job_candidate(false)
      candidate = job_candidate(true) if !disk_full? && !candidate
      return unless candidate
      job = find_job(candidate.id)
      job.update(slave_id: id, status: Job::STATUS_RUNNING) if job
      return job
    end
  end

  def schedule_fetch
    clumps = oldest_fetchable_clumps(CLUMPS_TO_SCHEDULE)
    return clumps if clumps.empty?
    clumps.each do |clump|
      clump.code_set.repository.enlistments.map(&:project).each do |project|
        project.schedule_fetch(DEFAULT_JOB_PRIORITY)
        @slave.logs.create!(message: I18n.t('slaves.auto_scheduled_fetch', id: project.id, name: project.name))
      end
    end
  end

  def job_candidate(create_clump = false)
    or_create = create_clump ? 'OR TRUE' : 'OR clumps.slave_id IS NULL'
    Job.joins('LEFT OUTER JOIN clumps on clumps.code_set_id = jobs.code_set_id')
      .where(status: Job::STATUS_SCHEDULED)
      .where('jobs.slave_id IS NULL OR jobs.slave_id = ?', id)
      .where("COALESCE(wait_until, '1980-01-01') <= now() at time zone 'utc'")
      .where("jobs.code_set_id IS NULL OR clumps.slave_id=#{id} #{or_create}")
      .where(type: @allowed_types)
      .order(priority: :desc, slave_id: :asc)
      .first
  end

  def find_job(job_id)
    return [] unless @allowed_types.present?
    Job.where(id: job_id, status: Job::STATUS_SCHEDULED)
      .where('jobs.slave_id IS NULL OR jobs.slave_id = ?', id)
      .where("COALESCE(wait_until, '1980-01-01') <= now() at time zone 'utc'")
      .where(type: @allowed_types)
      .take
  end
end
