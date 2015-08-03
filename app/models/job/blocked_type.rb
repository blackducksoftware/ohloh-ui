class Job::BlockedType
  delegate :id, :blocked_types, :disk_full?, :too_busy_for_new_job?, to: :@slave

  def initialize
    @slave = Slave.local
    @all = Job.send(:subclasses)
  end

  def allowed
    return [] if running_job_counts.values.sum >= Slave.max_jobs
    @all - (permanent + current)
  end

  private

  def current
    currently_blocked = on_high_load + too_busy + on_full_disk + too_many_jobs_of_the_same_type
    currently_blocked.uniq
  end

  def permanent
    blocked_types.to_s.strip.split(/\W+/).compact.map do |type|
      Kernel.const_get(type)
    end.sort_by(&:to_s).uniq
  end

  def running_job_counts
    Job.running.where(slave_id: id).group(:type).count
  end

  def on_high_load
    return [] unless LoadAverage.too_high?
    @all.select(&:db_intensive?)
  end

  def too_busy
    return [] unless too_busy_for_new_job?
    @all.select { |type| type.cpu_intensive? || type.disk_intensive? }
  end

  def on_full_disk
    return [] unless disk_full?
    @all.select(&:consumes_disk?)
  end

  def too_many_jobs_of_the_same_type
    @all.select { |type| running_job_counts[type.to_s].to_i >= Slave.max_jobs_per_type }
  end
end
