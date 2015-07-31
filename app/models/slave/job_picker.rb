class Slave::JobPicker
  DEFAULT_JOB_PRIORITY = -10
  CLUMPS_TO_SCHEDULE = 50

  delegate :id, :allowed?, :blocked_types, :disk_full?, :too_busy_for_new_job?, :oldest_fetchable_clumps, to: :@slave

  def initialize
    @slave = Slave.local
    @all_types = Job.send(:subclasses)
    @allowed_types = @all_types - currently_blocked_types
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

  def currently_blocked_types
    return @all_types if running_job_counts.values.sum >= Slave.max_jobs

    result = permanently_blocked_types

    @all_types.each { |c| result << c if c.db_intensive? } if LoadAverage.too_high?

    @all_types.each { |c| result << c if c.cpu_intensive? || c.disk_intensive? } if too_busy_for_new_job?

    @all_types.each { |c| result << c if c.consumes_disk? } if disk_full?

    @all_types.each do |c|
      result << c if (running_job_counts[c.to_s] || 0) >= Slave.max_jobs_per_type
    end

    result.sort_by(&:to_s).uniq
  end

  def schedule_fetch
    clumps = oldest_fetchable_clumps(CLUMPS_TO_SCHEDULE)
    return clumps if clumps.empty?
    clumps.each do |clump|
      clump.code_set.repository.enlistments.each do |enlistment|
        enlistment.project.schedule_fetch(DEFAULT_JOB_PRIORITY)
        @slave.logs.create!(message: I18n.t('slaves.auto_scheduled_fetch',
                                            id: enlistment.project_id, name: enlistment.project.name))
      end
    end
  end

  def permanently_blocked_types
    blocked_types.to_s.strip.split(/\W+/).compact.map do |type|
      Kernel.const_get(type)
    end.sort_by(&:to_s).uniq
  end

  def job_candidate(create_clump = false)
    or_create = create_clump ? 'OR TRUE' : 'OR clumps.slave_id IS NULL'
    Job.joins('LEFT OUTER JOIN clumps on clumps.code_set_id = jobs.code_set_id')
       .where(status: Job::STATUS_SCHEDULED)
       .where('jobs.slave_id IS NULL OR jobs.slave_id = ?', id)
       .where("COALESCE(wait_until, '1980-01-01') <= now() at time zone 'utc'")
       .where("jobs.code_set_id IS NULL OR clumps.slave_id=#{id} #{or_create}")
       .where(type: @allowed_types)
       .order({ priority: :desc, slave_id: :asc })
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

  def running_job_counts
    Job.where(status: Job::STATUS_RUNNING, slave_id: id).group(:type).count
  end
end
