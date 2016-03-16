class ProjectSecurityScore
  include Releases
  include ReleaseWeightCalculation
  include AgeWeightCalculation

  attr_accessor :uuid, :errors

  def initialize(uuid)
    self.uuid = uuid
    handle_errors
    hanlde_empty_data if errors.nil?
    @result = compute if errors.nil?
  end

  def pss
    @result[1]
  end

  def pvs
    @result[0]
  end

  def compute
    @json_data ||= fetch_json
    age_weight_hash = age_weight
    mrw_hash = major_release_weight
    mrsw_hash = minor_release_sequence_weight
    scores = version_release_raw_scores
    rvs_hash, month_credit = get_rvw_stats(age_weight_hash, mrw_hash, mrsw_hash, scores)
    pvs, pss = compute_pvs_pss(rvs_hash, month_credit, age_weight_hash)
    [pvs, pss]
  end

  def compute_pvs_pss(rvs_hash, month_credit, age_weight_hash)
    pvs = rvs_hash.values.inject(:+).round(3)
    sum_of_rvwa = month_credit.values.inject(:+).round(1)
    sum_of_age_weight = (age_weight_hash.values.reduce({}, :merge)).keys.inject(:+).round(1)
    pss = (sum_of_rvwa / sum_of_age_weight * 100).round(3)
    [pvs, pss]
  end

  def fetch_json
    @kb_data ||= load_json
    json_data = {}
    json_data['cves'] = @kb_data['cves']
    json_data['releases'] = update_release_date_format(@kb_data['releases'])
    json_data
  end

  def load_json
    url = open(ENV['KB_PROJECT_DETAIL'] + uuid + '?authToken=' + ENV['KB_AUTH_TOKEN'])
    kb_data = JSON.load(url)
    kb_data
  end

  def handle_errors
    return self.errors = { no_uuid: I18n.t('project_security_score.no_uuid') } if uuid.blank?
    @kb_data ||= load_json
    if @kb_data['cves'].empty? || @kb_data['releases'].empty?
      self.errors = { no_data: I18n.t('project_security_score.no_data') }
    end
  rescue OpenURI::HTTPError
    self.errors = { http_error: I18n.t('project_security_score.404_error') }
  end

  def hanlde_empty_data
    @json_data ||= fetch_json
    self.errors = { no_data: I18n.t('project_security_score.no_data') } if version_release_date_series.empty?
  end
end
