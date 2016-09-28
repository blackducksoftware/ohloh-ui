class ProjectSecuritySet < ActiveRecord::Base
  belongs_to :project
  has_many :releases
  has_many :vulnerabilities, -> { uniq }, through: :releases
end
