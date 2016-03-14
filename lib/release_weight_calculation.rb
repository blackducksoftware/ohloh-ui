module ReleaseWeightCalculation

  def compute_major_release_weight(major_release)
    major_release_weight_hash = {}
    major_release.each_with_index do |version, index|
      major_release_weight_hash.merge!(version => (((index + 1.0) / major_release.count) * 100).round(3))
    end
    major_release_weight_hash
  end

  def major_release_weight
    major_release = check_major_version #need to work
    mrw = compute_major_release_weight(major_release)
    Hash[mrw.to_a.reverse]
  end

  def check_major_version
    major_release = major_releases
    if (compute_latest_versions.map { |version| valid_version?(version) }).all?
      recent_release_version = compute_latest_versions.first.scan(/\d+/).first
      major_release -= [recent_release_version.to_i]
    end
    major_release
  end

  def minor_release_sequence_weight
    major_releases.each_with_object({}) do |major_version, mrsw|
      weightage_hash = {}
      mva = get_mva(major_version)
      weight_per_mr = 1.0 / mva.count
      mva.each_with_index do |(version, date), index|
        weightage_hash.merge!(version => [(1 - (index) * weight_per_mr).round(3), date])
      end
      mrsw.merge!(weightage_hash)
    end
  end

  def get_mva(major_version)
    mva = {}
    version_release_date_series.select { |k, v| mva.merge!(k => v) if k.scan(/\d+/).first.to_i == major_version }
    Hash[mva.sort_by { |_k, v| v }.reverse]
  end

  def get_rvw_stats(age_weight_hash, mrw, mrsw, version_cve_sum)
    release_version_score = {}
    month_credits = {}
    age_weight_hash.each do |month_index, hash|
      rvwm, versions_sum = generate_rvwm(hash, mrw, mrsw, version_cve_sum)
      release_version_score.merge!(month_index => rvwm.round(3))
      mcv = genarate_month_credits(month_index, age_weight_hash, versions_sum, release_version_score)
      month_credits.merge!(month_index => mcv)
    end
    [release_version_score, month_credits]
  end

  def generate_rvwm(hash, mrw, mrsw, version_cve_sum)
    rvwm = 0
    versions_sum = 0
    hash.values.flatten.each do |version|
      aw = hash.keys.first
      mvw = mrw[version.scan(/\d+/).first.to_i]
      mvw = (mvw == 0 ? 1 : mvw)
      single_release_version_weight = (aw * mvw * mrsw[version].first * version_cve_sum[version]) / 100.0
      rvwm += single_release_version_weight
      versions_sum += version_cve_sum[version]
    end
    [rvwm, versions_sum]
  end

  def genarate_month_credits(month_index, age_weight_hash, versions_sum, release_version_score)
    release_weighted_score = {}
    versions_sum = versions_sum == 0 ? 1 : versions_sum
    release_weighted_score.merge!(month_index => (release_version_score[month_index] / versions_sum).round(3))
    mcv = (age_weight_hash[month_index].keys.first - release_weighted_score[month_index]).round(3)
    mcv
  end
end
