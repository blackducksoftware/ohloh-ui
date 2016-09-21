module VulnerabilitiesHelper
  def major_releases(releases)
    releases.map do |r|
      r[:version].scan(/^\d+/)
    end.flatten.uniq.sort
  end
end
