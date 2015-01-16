class ProjectLicense < ActiveRecord::Base
  belongs_to :project
  belongs_to :license

  acts_as_editable
  acts_as_protected parent: :project

  validates :license_id, presence: true,
                         uniqueness: { scope: :project_id }
end
