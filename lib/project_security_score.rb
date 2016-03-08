# rubocop:disable Metrics/ModuleLength
module ProjectSecurityScore
  @release_version_weight = {}
  @release_weighted_score = {}
  @release_version_score = {}
  @month_credit = {}
  @error = {}

  module_function

  def get_uri(uuid)
    return @error['error'] = %w(no_uuid no_uuid) if uuid.empty?
    url = open(ENV['KB_PROJECT_DETAIL'] + uuid + '?authToken=' + ENV['KB_AUTH_TOKEN'])
    json_data = JSON.load(url)
    @error['error'] = ['#', '#'] if json_data['cves'].nil? || json_data['releases'].nil?
    return json_data
  rescue OpenURI::HTTPError
    return @error['error'] = %w(HTTP_404_Error HTTP_404_Error)
  end

  def validate_version(version)
    return true if Patterns::RC_ALPHA_BETA_CHECK =~ version ||
                   version.split(/\W+/).map { |v| /^[A-z]+$/.match(v) }.any?
  end

  def get_range(releases)
    recent_release_date = releases.max_by { |hash| hash['releasedOn'] }['releasedOn']
    (recent_release_date - 5.years)..recent_release_date
  end

  def get_version_raw_score(releases, range, cves)
    version_release_hash, version_raw_score = {}
    version_raw_score = {}
    releases.each do |hash|
      if range.cover?(hash['releasedOn'])
        version_release_hash.merge!(hash['version'] => hash['releasedOn'])
        version_raw_score.merge!(severity_stats(hash['version'], hash['cveIds'], cves))
      end
    end
    [version_release_hash, version_raw_score]
  end

  def severity_stats(version, cveids, cves)
    sum = 0
    versionstas_hash = {}
    cveids.each do |cveid|
      sum += cves[cveid]['score'] if cves.keys.include?(cveid) && !cves[cveid]['score'].nil?
    end
    versionstas_hash[version] = sum.round(3)
    versionstas_hash
  end

  def age_weight(version_release_hash, recent_release_date, old_release_date)
    aw_hash = {}
    months_ago_array = get_months_ago_array(recent_release_date, old_release_date)
    months_ago_array.each_with_index do |date, index|
      ver_arr = []
      df = Math.exp(-(0.05 * (index + 1)))
      range = date.first..date.last
      version_release_hash.select { |version, release_date| ver_arr << version if range.include?(release_date) }
      aw_hash.merge!(index + 1 => { df.round(4) => ver_arr })
    end
    aw_hash
  end

  def get_months_ago_array(recent_release_date, old_release_date)
    number_of_months = get_number_of_months(recent_release_date, old_release_date)
    number_of_months.times.each_with_object([]) do |count, array|
      array << [(recent_release_date - count.months).beginning_of_month,
                (recent_release_date - count.months).end_of_month]
    end
  end

  def get_number_of_months(recent_release_date, old_release_date)
    (recent_release_date.year * 12 + recent_release_date.month) - (old_release_date.year * 12 + old_release_date.month)
  end

  def update_rvm_hash(month_ver_hash, latest_ver_num)
    version_arr = month_ver_hash.values.flatten
    month_ver_hash.values.flatten.each do |version|
      version_arr -= [version] if version.scan(/\d+/).first == latest_ver_num
    end
    month_ver_hash.update(month_ver_hash) { |_key, _v1| version_arr }
  end

  def major_release_weight(version_release_hash)
    major_release = version_release_hash.keys.map { |v| v.scan(/\d+/).first.to_i }.uniq.sort
    latest_vers = get_latest_ver_array(version_release_hash, major_release)
    major_release = check_major_version(latest_vers, major_release)
    major_version_count = major_release.count
    major_release_weight = get_mrw_hash(major_release, major_version_count)
    [major_release, Hash[major_release_weight.to_a.reverse]]
  end

  def get_mrw_hash(major_release, major_version_count)
    major_release_weight = {}
    major_release.each_with_index do |version, index|
      major_release_weight.merge!(version => (((index + 1.0) / major_version_count) * 100).round(3))
    end
    major_release_weight
  end

  def check_major_version(latest_vers, major_release)
    if (latest_vers.map { |version| validate_version(version) }).all?
      recent_release_version = latest_vers.first.scan(/\d+/).first
      major_release -= [recent_release_version.to_i]
    end
    major_release
  end

  def get_latest_ver_array(version_release_hash, major_release)
    version_release_hash.keys.each_with_object([]) do |version, latest_vers|
      latest_vers << version if version.scan(/\d+/).first == major_release.last.to_s
    end
  end

  def check_for_update_age_weight(age_weight, version_release_hash)
    major_release = version_release_hash.keys.map { |v| v.scan(/\d+/).first.to_i }.uniq.sort
    latest_vers = get_latest_ver_array(version_release_hash, major_release.last.to_s)
    if (latest_vers.map { |version| validate_version(version) }).all?
      age_weight = update_age_weight(age_weight, latest_vers)
    end
    age_weight
  end

  def update_age_weight(age_weight, latest_vers)
    recent_release_version = latest_vers.first.scan(/\d+/).first
    age_weight.update(age_weight) { |_key, month_ver_hash| update_rvm_hash(month_ver_hash, recent_release_version) }
  end

  def minor_release_sequence_weight(major_release, version_release_hash)
    major_release.each_with_object({}) do |major_version, mrsw|
      weightage_hash = {}
      mva = get_mva(version_release_hash, major_version)
      weight_per_mr = 1.0 / mva.count
      mva.each_with_index do |(version, date), index|
        weightage_hash.merge!(version => [(1 - (index) * weight_per_mr).round(3), date])
      end
      mrsw.merge!(weightage_hash)
    end
  end

  def get_mva(version_release_hash, major_version)
    mva = {}
    version_release_hash.select { |k, v| mva.merge!(k => v) if k.scan(/\d+/).first.to_i == major_version }
    Hash[mva.sort_by { |_k, v| v }.reverse]
  end

  def get_rvw_stats(age_weight, major_release_weight, mrsw, version_cve_sum)
    age_weight.each do |months_ago, hash|
      @rvwm = 0
      @versions_sum = 0
      get_rvw_stats_part_1(hash, major_release_weight, mrsw, version_cve_sum)
      get_rvw_stats_part_2(months_ago, age_weight)
    end
  end

  def get_rvw_stats_part_1(hash, major_release_weight, mrsw, version_cve_sum)
    hash.values.flatten.each do |version|
      aw = hash.keys.first
      mvw_check = major_release_weight[version.scan(/\d+/).first.to_i]
      mvw = mvw_check.nil? ? 0 : mvw_check
      get_rvw_stats_part_1_compute(version, aw, mvw, mrsw, version_cve_sum)
    end
  end

  def get_rvw_stats_part_1_compute(version, aw, mvw, mrsw, version_cve_sum)
    @rvwv = (aw * mvw * mrsw[version].first * version_cve_sum[version]) / 100.0
    @release_version_weight.merge!(version => @rvwv.round(3))
    @rvwm += @release_version_weight[version]
    @versions_sum += version_cve_sum[version]
  end

  def get_rvw_stats_part_2(months_ago, age_weight)
    @release_version_score.merge!(months_ago => @rvwm.round(3))
    @versions_sum = @versions_sum == 0 ? 1 : @versions_sum
    @release_weighted_score.merge!(months_ago => (@release_version_score[months_ago] / @versions_sum).round(3))
    mcv = (age_weight[months_ago].keys.first - @release_weighted_score[months_ago]).round(3)
    @month_credit.merge!(months_ago => mcv)
  end

  def update_releases(releases)
    releases.flatten.compact.each do |hash|
      hash['releasedOn'] = Time.zone.at(hash['releasedOn'] / 1000).to_date
    end
  end

  def self.get_pvs_pss(uuid)
    json_data = get_uri(uuid)
    return @error['error'] if @error.key?('error')
    get_cves_releases_range(json_data)
    version_release_raw_array = get_version_raw_score(@releases, @range, @cves)
    return ['#', '#'] if version_release_raw_array.first.empty? || version_release_raw_array.last.empty?
    compute_raw_data(@range, version_release_raw_array)
    compute_pvs_pss
  end

  def get_cves_releases_range(json_data)
    @cves = json_data['cves']
    @releases = update_releases(json_data['releases'])
    @range = get_range(@releases)
    return ['#', '#'] if @releases.empty? || @cves.empty?
  end

  def compute_raw_data(range, version_release_raw_array)
    @age_weight = age_weight(version_release_raw_array[0], range.last, range.first)
    major_release_weight_array = major_release_weight(version_release_raw_array[0])
    @age_weight = check_for_update_age_weight(@age_weight, version_release_raw_array[0])
    mrsw = minor_release_sequence_weight(major_release_weight_array[0], version_release_raw_array[0])
    version_cve_sum = version_release_raw_array[1]
    get_rvw_stats(@age_weight, major_release_weight_array[1], mrsw, version_cve_sum)
  end

  def compute_pvs_pss
    pvs = @release_version_score.values.inject(:+).round(3)
    sum_of_rvwa = @month_credit.values.inject(:+).round(1)
    sum_of_age_weight = (@age_weight.values.reduce({}, :merge)).keys.inject(:+).round(1)
    pss = (sum_of_rvwa / sum_of_age_weight * 100).round(3)
    [pvs, pss]
  end
end
# rubocop:enable Metrics/ModuleLength
