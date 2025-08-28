# frozen_string_literal: true

class ProjectSecuritySet < ApplicationRecord
  has_many :releases
  belongs_to :project, optional: true

  def vulnerabilities
    vuln_ids = ReleasesVulnerability.where(release_id: releases.pluck(:id)).pluck(:vulnerability_id).uniq
    Vulnerability.where(id: vuln_ids)
  end

  def most_recent_releases
    @most_recent_releases ||= releases.order(released_on: :asc).last(10)
  end

  def most_recent_vulnerabilities?
    ReleasesVulnerability.where(release_id: most_recent_releases.map(&:id)).any?
  end

  def matching_releases(version_number)
    releases.where("version ~ '^#{version_number}\\.'")
  end

  def oldest_vulnerability
    vulnerabilities.order(published_on: :asc).first
  end

  # rubocop:disable Metrics/MethodLength
  def release_history(release_ids = [], bdsa_visible = false)
    condition = "where R.project_security_set_id = #{id}"
    condition += " AND R.id IN(#{release_ids.join(',')})" if release_ids.present?
    non_bdsa_query = " AND (V.cve_id not like 'BDSA%' OR V.cve_id is null)"
    bdsa_query = " AND V.cve_id like 'BDSA%'"
    condition += non_bdsa_query unless bdsa_visible
    sql = <<-SQL.squish
      select R.id, R.version, R.released_on, sum (case when V.severity = 0 #{non_bdsa_query} then 1 else 0 end) low,
      sum (case when V.severity = 1 #{non_bdsa_query} then 1 else 0 end) medium,
      sum (case when V.severity = 2 #{non_bdsa_query} then 1 else 0 end) high,
      sum (case when V.severity = 3 #{non_bdsa_query} then 1 else 0 end) critical,
      sum (case when V.severity is null and V.id is not null #{non_bdsa_query} then 1 else 0 end) unknown_severity,
      sum (case when V.severity = 0 #{bdsa_query} then 1 else 0 end) bdsa_low,
      sum (case when V.severity = 1 #{bdsa_query} then 1 else 0 end) bdsa_medium,
      sum (case when V.severity = 2 #{bdsa_query} then 1 else 0 end) bdsa_high,
      sum (case when V.severity = 3 #{bdsa_query} then 1 else 0 end) bdsa_critical,
      sum (case when V.severity is null and V.id is not null #{bdsa_query} then 1 else 0 end) bdsa_unknown_severity
      from releases R left outer join releases_vulnerabilities RV on RV.release_id = R.id
      left outer join vulnerabilities V on V.id = RV.vulnerability_id #{condition} group by R.id order by R.released_on asc;
    SQL
    self.class.find_by_sql(sql)
  end
  # rubocop:enable Metrics/MethodLength

  def self.ransackable_attributes(_auth_object = nil)
    authorizable_ransackable_attributes
  end

  def self.ransackable_associations(_auth_object = nil)
    authorizable_ransackable_associations
  end
end
