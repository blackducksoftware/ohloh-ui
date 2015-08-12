class SlaveDaemon
  def run
    Dir.chdir(Rails.root)
    trap_exit
    require_environment_to_ensure_db_connection
    run_job_loop
  end

  private

  def pids
    @pids ||= []
  end

  def run_job_loop
    slave.logs.create!(message: I18n.t('slaves.daemon_started'))
    Slave::Sync.new.execute

    job_loop
  rescue
    slave.logs.create!(message: $ERROR_INFO.inspect, level: SlaveLog::FATAL)
    raise
  end

  def job_loop
    loop do
      remove_pids_for_completed_processes
      update_hardware_stats
      reset_jobs_count_and_log_failed_jobs

      sleep(ENV['DISABLED_SLAVE_LOOP_INTERVAL'].to_i) && next unless slave.allowed?

      fork_jobs
      sleep ENV['INTERVAL_BEFORE_CHECKING_JOBS_COMPLETION'].to_i
      remove_pids_for_completed_processes
      reset_jobs_count_and_log_failed_jobs
    end
  end

  def remove_pids_for_completed_processes
    pids.delete_if { |pid| Process.waitpid(pid, Process::WNOHANG) }
  end

  def update_hardware_stats
    slave.update_used_percent
    slave.update_load_average
    slave.save!
  end

  def reset_jobs_count_and_log_failed_jobs
    job_ids = running_job_ids
    reset_jobs_count(job_ids)
    log_failed_jobs(job_ids)
  end

  def reset_jobs_count(job_ids)
    @jobs_count = slave.jobs.running.where(id: job_ids).size
  end

  def log_failed_jobs(job_ids)
    slave.jobs.running.where.not(id: job_ids).each do |job|
      slave.logs.create!(message: I18n.t('slaves.could_not_find_process_mark_as_failed'),
                         job_id: job.id, code_set_id: job.code_set_id, level: SlaveLog::ERROR)
      job.update(status: Job::STATUS_FAILED, exception: I18n.t('slaves.could_not_find_process'))
    end
  end

  def trap_exit
    trap 'EXIT' do
      slave.logs.create!(message: I18n.t('slaves.daemon_stopped'))
    end
  end

  def require_environment_to_ensure_db_connection
    require File.expand_path('../../config/environment', __FILE__)
  end

  def pick_job_unless_maxed_out
    return if @jobs_count >= Slave.max_jobs
    Slave::JobPicker.new.execute
  end

  def fork_jobs
    loop do
      job = pick_job_unless_maxed_out
      return unless job
      pids << job.fork!
      @jobs_count += 1
      sleep ENV['INTERVAL_BETWEEN_EACH_JOB_FORK'].to_i
    end
  end

  def running_job_ids
    running_job_processes = `ps x | grep -E 'Job [0-9]+'`.lines.to_a
    running_job_processes.map { |ps| ps.slice(/(?<=Job )\d+/) }.compact.map(&:to_i)
  end

  def slave
    Slave.local
  end
end
