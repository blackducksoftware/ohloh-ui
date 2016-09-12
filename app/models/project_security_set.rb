class ProjectSecuritySet < ActiveRecord::Base
  belongs_to :project
  has_many :pss_release_vulnerabilities
  has_many :releases, -> { uniq }, through: :pss_release_vulnerabilities
  has_many :vulnerabilities, -> { uniq }, through: :pss_release_vulnerabilities
end
