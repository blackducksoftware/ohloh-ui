class Release < ActiveRecord::Base
  has_many :pss_release_vulnerabilities
  has_many :vulnerabilities, -> { uniq }, through: :pss_release_vulnerabilities
end
