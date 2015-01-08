class ProjectLicense < ActiveRecord::Base
  belongs_to :project
  belongs_to :license

  acts_as_editable

  validates :license_id, presence: true,
                         uniqueness: { scope: :project_id }
end
