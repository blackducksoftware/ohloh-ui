# frozen_string_literal: true

class ProjectAnalysisJob < Job
  self.table_name = "#{ENV['ANALYTICS_SCHEMA']}.jobs"

  def progress_message
    I18n.t 'jobs.analyze_job.progress_message', name: project.name
  end
end
