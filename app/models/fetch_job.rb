class FetchJob < Job
  def progress_message
    I18n.t 'jobs.fetch_job.progress_message'
  end
end
