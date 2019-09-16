# frozen_string_literal: true

class VitaJob < Job
  scope :schedule_account_analysis, lambda { |account, delay = 0|
    delayed_time = Time.current + delay
    job = where(account_id: account.id).where.not(status: Job::STATUS_COMPLETED).take
    if job
      job.update(wait_until: delayed_time)
    else
      create(account_id: account.id, wait_until: delayed_time)
    end
  }

  scope :schedule_account_analysis_for_project, lambda { |project|
    project.positions.includes(:account).find_each { |position| schedule_account_analysis(position.account) }
  }

  def progress_message
    I18n.t 'jobs.vita_job.progress_message', name: account.name
  end
end
