# frozen_string_literal: true

class ImportJob < FisJob
  def progress_message
    I18n.t 'jobs.import_job.progress_message'
  end
end
