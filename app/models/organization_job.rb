# frozen_string_literal: true

class OrganizationJob < Job
  def progress_message
    I18n.t 'jobs.organization_job.progress_message', name: organization.name
  end
end
