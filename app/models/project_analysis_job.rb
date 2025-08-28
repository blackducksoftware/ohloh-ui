# frozen_string_literal: true

class ProjectAnalysisJob < Job
  self.table_name = "#{ENV.fetch('ANALYTICS_SCHEMA', nil)}.jobs"

  def progress_message
    I18n.t 'jobs.analyze_job.progress_message', name: project.name
  end
end
