class VitaJob < Job
  # NOTE: Replace schedule_vita with schedule_account_analysis
  scope :schedule_account_analysis, lambda { |account, delay = 0|
    delayed_time = Time.now + delay
    job = where(account_id: account.id).where.not(status: Job::STATUS_COMPLETED).take
    if job
      job.update_attributes(wait_until: delayed_time)
    else
      create(account_id: account.id, wait_until: delayed_time)
    end
  }

  scope :schedule_account_analysis_for_project, lambda { |project|
    project.positions.includes(:account).each { |position| schedule_account_analysis(position.account) }
  }
end
