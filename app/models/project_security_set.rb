class ProjectSecuritySet < ActiveRecord::Base
  belongs_to :project
  has_many :releases
end
