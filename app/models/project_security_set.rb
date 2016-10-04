class ProjectSecuritySet < ActiveRecord::Base
  has_many :releases
  has_many :vulnerabilities, -> { uniq }, through: :releases
  belongs_to :project

  def most_recent_releases
    @recent_releases_ ||= releases.order(released_on: :asc).last(10)
  end

  def most_recent_vulnerabilities
    @recent_vulnerabilities_ ||= most_recent_releases.map(&:vulnerabilities)
  end

  def most_recent_vulnerabilities?
    most_recent_releases.present? && most_recent_vulnerabilities.flatten.present?
  end

  def matching_releases(version_number)
    releases.where("version ~ '^#{version_number}[\.]' OR version ~ '^#{version_number}$'")
  end

  def find_latest_release_from_major_version(version_number)
    matching_releases(version_number).latest
  end

  def oldest_vulnerability
    vulnerabilities.order(published_on: :asc).first
  end

  def release_history(release_ids = [])
    condition = "where R.project_security_set_id = #{id}"
    condition += " AND R.id IN(#{release_ids.join(',')})" if release_ids.present?
    sql = <<-SQL
      select R.version, R.released_on, T.low, T.medium, T.high from releases R inner join ( select R.id, R.released_on,
      sum (case V.severity when 0 then 1 else 0 end) low, sum (case V.severity when 1 then 1 else 0 end) medium,
      sum (case V.severity when 2 then 1 else 0 end) high from releases R full outer join releases_vulnerabilities RV
      on RV.release_id = R.id full outer join vulnerabilities V on V.id = RV.vulnerability_id #{condition} group by R.id ) T on T.id = R.id;
    SQL
    self.class.find_by_sql(sql)
  end
end
