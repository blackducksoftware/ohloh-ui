module VulnerabilitiesHelper
  def major_releases(releases)
    releases.map do |r|
      r[:version].scan(/^\d+/)
    end.flatten.uniq.sort
  end

  def map_vulnerabilities_to_releases(releases)
    data = []
    releases.each do |r|
      data << { id: r.id,
                version: r.version,
                released_on: r.released_on,
                high_vulns: r.vulnerabilities.high,
                medium_vulns: r.vulnerabilities.medium,
                low_vulns: r.vulnerabilities.low }
    end
    data
  end
end
