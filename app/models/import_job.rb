# frozen_string_literal: true

class ImportJob < Job
  def progress_message
    I18n.t 'jobs.import_job.progress_message'
  end
end
