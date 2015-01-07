class ProjectLicense < ActiveRecord::Base
  belongs_to :project
  belongs_to :license

  acts_as_editable edit_description: ->(project_license) { "Added license #{project_license.license.nice_name}" }
end
