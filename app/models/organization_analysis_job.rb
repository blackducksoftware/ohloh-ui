# frozen_string_literal: true

class OrganizationAnalysisJob < Job
  def progress_message
    I18n.t 'jobs.organization_analysis_job.progress_message', name: organization.name
  end
end
