module Releases
  def update_release_date_format(releases)
    releases.flatten.compact.each do |hash|
      hash['releasedOn'] = Time.zone.at(hash['releasedOn'] / 1000).to_date
    end
  end

  def five_years_date_range
    recent_release_date = @json_data['releases'].max_by { |hash| hash['releasedOn'] }['releasedOn']
    oldest_release_date = (recent_release_date - 5.years)
    oldest_release_date..recent_release_date
  end

  def valid_release?(release, release_date, range)
    release = valid_version?(release)
    within_range = range.cover?(release_date)
    within_range && (!release)
  end

  def valid_version?(release)
    Patterns::RC_ALPHA_BETA_CHECK =~ release || release.split(/\W+/).map { |v| /^[A-z]+$/.match(v) }.any?
  end

  def version_release_date_series
    @five_years_range ||= five_years_date_range
    @version_release_date_hash ||= compute_version_release_date_series
  end

  def compute_version_release_date_series
    version_release_date_hash = {}
    @five_years_range ||= five_years_date_range
    @json_data['releases'].each do |hash|
      release = hash['version']
      release_date = hash['releasedOn']
      if valid_release?(release, release_date, @five_years_range)
        version_release_date_hash.merge!(release => release_date)
      end
    end
    version_release_date_hash
  end

  def version_release_raw_scores
    version_release_score_hash = {}
    @json_data['releases'].each do |hash|
      release = hash['version']
      release_date = hash['releasedOn']
      cve_ids = hash['cveIds']
      if valid_release?(release, release_date, @five_years_range)
        version_release_score_hash.merge!(release => compute_cve_scores(cve_ids))
      end
    end
    version_release_score_hash
  end

  def compute_cve_scores(cve_ids)
    sum = 0
    cve_ids.each do |cveid|
      if @json_data['cves'].keys.include?(cveid) && !@json_data['cves'][cveid]['score'].nil?
        sum += @json_data['cves'][cveid]['score']
      end
    end
    sum.round(3)
  end

  def major_releases
    version_release_date_series.keys.map { |v| v.scan(/\d+/).first.to_i }.uniq.sort
  end

  def compute_latest_versions
    version_release_date_series.keys.each_with_object([]) do |version, latest_version|
      latest_version << version if version.scan(/\d+/).first == major_releases.last.to_s
    end
  end
end
