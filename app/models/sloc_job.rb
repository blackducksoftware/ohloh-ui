# frozen_string_literal: true

class SlocJob < FisJob
  def progress_message
    I18n.t 'jobs.sloc_job.progress_message'
  end
end
