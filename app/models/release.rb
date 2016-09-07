class Release < ActiveRecord::Base
  delegate :project, to: :project_security_set
  has_many :pss_release_vulnerabilities
  has_many :vulnerabilities, -> { uniq }, through: :pss_release_vulnerabilities
end
