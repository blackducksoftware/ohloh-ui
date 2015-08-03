class Job::Manager
  delegate :slave, :project, :repository, :after_completed, :set_process_title, :priority, :started_at, to: :@job

  def initialize(job)
    @job = job
  end

  def run
    @job.update(status: Job::STATUS_RUNNING, current_step: 0, started_at: Time.now.utc,
                current_step_at: Time.now.utc, slave: Slave.local)

    return if inactive_projects? && update_completed_status
    execute
    mark_as_complete
  rescue JobTooLongException
    handle_too_long_exception
  rescue
    handle_exception
  end

  private

  def update_completed_status
    @job.update(status: Job::STATUS_COMPLETED)
    slave.logs.create!(message: I18n.t('slaves.skipping_job'),
                       job_id: @job.id, code_set_id: @job.code_set_id)
    set_process_title('Completed')
  end

  def inactive_projects?
    if project
      project.deleted?
    elsif repository
      !repository.projects.any? { |p| !p.deleted? }
    end
  end

  def execute
    @job.work do |step, max_steps|
      @job.update(max_steps: max_steps, current_step: step, current_step_at: Time.now.utc,
                  exception: nil, backtrace: nil)
      set_process_title('Running')

      kill_long_running_job
    end
  end

  def mark_as_complete
    @job.update(status: Job::STATUS_COMPLETED)
    after_completed
    slave.logs.create!(message: I18n.t('slaves.job_completed'),
                       job_id: @job.id, code_set_id: @job.code_set_id)
    set_process_title('Completed')
  end

  def handle_too_long_exception
    slave.logs.create!(message: I18n.t('slaves.runtime_exceeded'),
                       job_id: @job.id, code_set_id: @job.code_set_id)
    @job.update(status: Job::STATUS_SCHEDULED, wait_until: Time.now.utc + 16.hours,
                exception: $ERROR_INFO.message, backtrace: $ERROR_INFO.backtrace.join("\n"))
  end

  def handle_exception
    slave.logs.create!(message: I18n.t('slaves.job_failed'),
                       job_id: @job.id, code_set_id: @job.code_set_id)
    @job.status = Job::STATUS_FAILED
    @job.exception = $ERROR_INFO.message
    @job.backtrace = $ERROR_INFO.backtrace.join("\n")
    @job.save
    @job.categorize_on_failure
  end

  def kill_long_running_job
    return if priority > 0 || !older_than_8_hours? || current_step.to_i >= max_steps.to_i ||
              !can_have_too_long_exception?

    fail JobTooLongException.new, 'Runtime limit exceeded.'
  end

  def older_than_8_hours?
    started_at < Time.now.utc - 8.hours
  end
end
