class OrganizationJob < Job
  def progress_message
    "Analyzing organization #{organization.name}"
  end
end
