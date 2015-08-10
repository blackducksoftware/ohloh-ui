module SlaveDaemon
  module_function

  INTERVAL_BETWEEN_EACH_JOB_FORK = 2
  INTERVAL_BEFORE_CHECKING_JOBS_COMPLETION = 5
  DISABLED_SLAVE_LOOP_INTERVAL = 60

  def run
    Dir.chdir(Rails.root)
    trap_exit
    require_environment_to_ensure_db_connection
    run_job_loop
  end

  private

  module_function

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
      wait_for_jobs_to_complete
      update_hardware_stats
      sync_running_jobs_count_with_db

      sleep(DISABLED_SLAVE_LOOP_INTERVAL) && next unless slave.allowed?

      fork_jobs
      sleep INTERVAL_BEFORE_CHECKING_JOBS_COMPLETION
      wait_for_jobs_to_complete
      sync_running_jobs_count_with_db
    end
  end

  def wait_for_jobs_to_complete
    # Clean up any forked processes that have completed
    pids.delete_if { |pid| Process.waitpid(pid, Process::WNOHANG) }
  end

  def update_hardware_stats
    slave.update_used_percent
    slave.update_load_average
    slave.save!
  end

  # The database expects that certain jobs are running.
  # If we can't actually find it running on this machine, mark the job as failed.
  def sync_running_jobs_count_with_db
    @jobs_count = 0

    slave.jobs.running.each do |job|
      if running_job_ids.include?(job.id)
        @jobs_count += 1
      else
        slave.logs.create!(message: I18n.t('slaves.could_not_find_process'),
                           job_id: job.id, code_set_id: job.code_set_id, level: SlaveLog::ERROR)
        job.update(status: Job::STATUS_FAILED, exception: 'SlaveDaemon could not find process for job.')
      end
    end
  end

  # TODO: Make this work.
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
      sleep INTERVAL_BETWEEN_EACH_JOB_FORK
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
