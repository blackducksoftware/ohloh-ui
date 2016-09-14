class ProjectSecuritySet < ActiveRecord::Base
  belongs_to :project
  has_many :pss_release_vulnerabilities
  has_many :releases, -> { uniq }, through: :pss_release_vulnerabilities
  has_many :vulnerabilities, -> { uniq }, through: :pss_release_vulnerabilities

  def most_recent_releases
    releases.order(released_on: :asc).last(10)
  end
end
