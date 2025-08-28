# frozen_string_literal: true

class OrganizationAnalysisJob < Job
  def progress_message
    I18n.t 'jobs.organization_analysis_job.progress_message', name: organization.name
  end

  def self.ransackable_attributes(_auth_object = nil)
    authorizable_ransackable_attributes
  end

  def self.ransackable_associations(_auth_object = nil)
    authorizable_ransackable_associations
  end
end
