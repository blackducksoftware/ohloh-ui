class Release < ActiveRecord::Base
  belongs_to :project_security_set
  has_and_belongs_to_many :vulnerabilities
end
