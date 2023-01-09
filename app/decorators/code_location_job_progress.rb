# frozen_string_literal: true

class CodeLocationJobProgress
  include ActionView::Helpers::DateHelper

  STATUS = { Job::STATUS_SCHEDULED => :waiting, Job::STATUS_QUEUED => :waiting,
             Job::STATUS_RUNNING => :running, Job::STATUS_FAILED => :failed,
             Job::STATUS_COMPLETED => :completed, Job::STATUS_RESTART => :waiting }.freeze

  delegate :best_code_set, :cl_update_event_time, to: :@code_location

  def initialize(enlistment)
    @code_location = enlistment.code_location
    @project = enlistment.project
    @job = FisJob.where(code_location_id: @code_location.id).incomplete_fis_jobs.first
  end

  def message
    return "Fetched at #{cl_update_event_time}" if code_location_is_updated?

    @job ? progress : no_job
  end

  private

  def code_location_is_updated?
    cl_update_event_time.to_i > @project.best_analysis.try(:updated_on).to_i
  end

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
    if sloc_set_code_set_time
      I18n.t 'repositories.job_progress.update_completed', at: time_ago_in_words(sloc_set_code_set_time)
    else
      code_location_id = @project.enlistments.pluck(:code_location_id)
      incomplete_job = FisJob.where(code_location_id: code_location_id).incomplete_fis_jobs.first
      return I18n.t 'repositories.job_progress.no_job' unless incomplete_job

      I18n.t('repositories.job_progress.blocked_by', status: STATUS[incomplete_job.status])
    end
  end

  def sloc_set_code_set_time
    best_code_set&.best_sloc_set && best_code_set.best_sloc_set.code_set_time
  end
end
