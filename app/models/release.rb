class Release < ActiveRecord::Base
  belongs_to :project_security_set
  has_many :vulnerabilities
end
