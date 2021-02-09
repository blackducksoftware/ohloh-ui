# frozen_string_literal: true

class FetchJob < FisJob
  def progress_message
    I18n.t 'jobs.fetch_job.progress_message'
  end
end
