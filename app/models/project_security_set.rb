class ProjectSecuritySet < ActiveRecord::Base
  belongs_to :project
  has_many :pss_release_vulnerabilities
  has_many :releases, -> { uniq }, through: :pss_release_vulnerabilities
  has_many :vulnerabilities, -> { uniq }, through: :pss_release_vulnerabilities

  def most_recent_releases
    @recent_releases_ ||= releases.order(released_on: :asc).last(10)
  end

  def all_releases
    releases.order(released_on: :asc)
  end

  def most_recent_vulnerabilities
    @recent_vulnerabilities_ ||= most_recent_releases.map(&:vulnerabilities)
  end

  def most_recent_vulnerabilities?
    most_recent_releases.present? && most_recent_vulnerabilities.flatten.present?
  end
end
