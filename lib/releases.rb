module Releases

  def update_release_date_format
    @json_data['releases'].flatten.compact.each do |hash|
      hash['releasedOn'] = Time.zone.at(hash['releasedOn'] / 1000).to_date
    end
  end

  def five_years_dange_range
    recent_release_date = @json_data['releases'].max_by { |hash| hash['releasedOn'] }['releasedOn']
    (recent_release_date - 5.years)..recent_release_date
  end

  def valid_release?(release, release_date)
    release = valid_version?(release)
    within_range = five_years_dange_range.cover?(release_date)
    within_range && (!release) #Needs work
  end

  def valid_version?(release)
    return Patterns::RC_ALPHA_BETA_CHECK =~ release || release.split(/\W+/).map { |v| /^[A-z]+$/.match(v) }.any?
  end

  def version_release_date_series
    version_release_date_hash = {}
    @json_data['releases'].each do |hash|
      release = hash['version']
      release_date = hash['releasedOn']
      version_release_date_hash.merge!(release => release_date) if valid_release?(release, release_date)
    end
    version_release_date_hash
  end

  def version_release_raw_scores
    version_release_score_hash = {}
    @json_data['releases'].each do |hash|
      release = hash['version']
      release_date = hash['releasedOn']
      cve_ids = hash['cveIds']
      version_release_score_hash.merge!({release => compute_cve_scores(cve_ids)}) if valid_release?(release, release_date)
    end
    version_release_score_hash
  end

  def compute_cve_scores(cve_ids)
    sum = 0
    cve_ids.each do |cveid|
      sum += @json_data['cves'][cveid]['score'] if @json_data['cves'].keys.include?(cveid) && !@json_data['cves'][cveid]['score'].nil? #need work
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
