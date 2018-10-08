class ProjectSecuritySet < ActiveRecord::Base
  has_many :releases
  has_many :vulnerabilities, -> { uniq }, through: :releases
  belongs_to :project

  def most_recent_releases
    @recent_releases_ ||= releases.order(released_on: :asc).last(10)
  end

  def most_recent_vulnerabilities?
    ReleasesVulnerability.where(release_id: most_recent_releases.map(&:id)).count > 0
  end

  def matching_releases(version_number)
    releases.where("version ~ '^#{version_number}\\.'")
  end

  def oldest_vulnerability
    vulnerabilities.order(published_on: :asc).first
  end

  def release_history(release_ids = [])
    condition = "where R.project_security_set_id = #{id}"
    condition += " AND R.id IN(#{release_ids.join(',')})" if release_ids.present?
    sql = <<-SQL
      select R.id, R.version, R.released_on, sum (case V.severity when 0 then 1 else 0 end) low,
      sum (case V.severity when 1 then 1 else 0 end) medium, sum (case V.severity when 2 then 1 else 0 end) high, sum (case when V.severity is null and V.id is not null then 1 else 0 end) unknown_severity
      from releases R left outer join releases_vulnerabilities RV on RV.release_id = R.id
      left outer join vulnerabilities V on V.id = RV.vulnerability_id #{condition} group by R.id order by R.released_on asc;
    SQL
    self.class.find_by_sql(sql)
  end
end
