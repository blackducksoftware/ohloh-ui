class RepositoryJobProgress
  include ActionView::Helpers::DateHelper

  STATUS = { Job::STATUS_SCHEDULED => :waiting, Job::STATUS_RUNNING => :running,
             Job::STATUS_FAILED => :failed, Job::STATUS_COMPLETED => :completed }.freeze

  delegate :best_code_set, to: :@repository

  def initialize(enlistment)
    @repository = enlistment.repository
    @project = enlistment.project
    @job = @repository.jobs.incomplete.first
  end

  def message
    @job ? progress : no_job
  end

  private

  def progress
    "#{@job.progress_message} (#{send(STATUS[@job.status])})"
  end

  def waiting
    I18n.t('repositories.job_progress.waiting')
  end

  def running
    if @job.current_step && @job.max_steps
      I18n.t('repositories.job_progress.running_at', at: "#{@job.current_step}/#{@job.max_steps}")
    else
      I18n.t('repositories.job_progress.running')
    end
  end

  def failed
    if @job.current_step_at.present?
      I18n.t 'repositories.job_progress.failed_at', at: time_ago_in_words(@job.current_step_at)
    else
      I18n.t 'repositories.job_progress.failed'
    end
  end

  def completed
    I18n.t 'repositories.job_progress.complete', at: time_ago_in_words(@job.current_step_at)
  end

  def no_job
    if sloc_set_logged_at
      I18n.t 'repositories.job_progress.update_completed', at: time_ago_in_words(sloc_set_logged_at)
    else
      incomplete_job = Job.where(repository: @project.repositories).incomplete.first
      return I18n.t 'repositories.job_progress.no_job' unless incomplete_job

      I18n.t('repositories.job_progress.blocked_by', status: STATUS[incomplete_job.status])
    end
  end

  def sloc_set_logged_at
    best_code_set && best_code_set.best_sloc_set && best_code_set.best_sloc_set.logged_at
  end
end
