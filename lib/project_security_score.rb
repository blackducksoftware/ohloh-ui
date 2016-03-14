class ProjectSecurityScore
  extend Releases
  extend ReleaseWeightCalculation
  extend AgeWeightCalculation
  class << self
    def compute(uuid)
      @json_data = fetch_json(uuid)
      update_release_date_format
      age_weight_hash = age_weight
      mrw_hash = major_release_weight
      mrsw_hash = minor_release_sequence_weight
      scores = version_release_raw_scores
      rvs_hash, month_credit = get_rvw_stats(age_weight_hash, mrw_hash, mrsw_hash, scores)
      pvs, pss = compute_pvs_pss(rvs_hash, month_credit, age_weight_hash)
    end

    def compute_pvs_pss(rvs_hash, month_credit, age_weight_hash)
      pvs = rvs_hash.values.inject(:+).round(3)
      sum_of_rvwa = month_credit.values.inject(:+).round(1)
      sum_of_age_weight = (age_weight_hash.values.reduce({}, :merge)).keys.inject(:+).round(1)
      pss = (sum_of_rvwa / sum_of_age_weight * 100).round(3)
      [pvs, pss]
    end

    def fetch_json(uuid)
      url = open(ENV['KB_PROJECT_DETAIL'] + uuid + '?authToken=' + ENV['KB_AUTH_TOKEN'])
      kb_data = JSON.load(url)
      json_data = {}
      json_data['cves'] = kb_data['cves']
      json_data['releases'] = kb_data['releases']
      json_data
    end
  end
end
