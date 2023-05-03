# frozen_string_literal: true

module Api::VulnerabilitiesHelper
  include MarkdownHelper

  def humanize_datetime(time_string)
    return 'not available' if time_string.blank?

    time_string.to_datetime.strftime('%b %d, %Y')
  end

  def bdsa_cve_id(data)
    return unless data

    cve_id = data['href'].split('/').last
    cve_url = ENV['NVD_LINK'] + cve_id
    link_to(cve_id, cve_url, target: '_blank', rel: 'noopener')
  end

  def cvss3_severity(data, type = nil)
    score = type == 'CVE' ? data['baseScore'] : data['temporalMetrics']['score']
    "#{score} #{data['severity'].titleize}"
  end

  def bdsa_cvss(cvss_data)
    return unless cvss_data

    [cvss_data['temporalMetrics'].try { |metric| metric['score'] }.to_f,
     cvss_data['baseScore'],
     cvss_data['exploitabilitySubscore'],
     cvss_data['impactSubscore']]
  end

  def bdsa_vulnerability_age(start_date)
    no_of_days = number_with_delimiter((Time.zone.today - Date.parse(start_date)).to_i, delimiter: ',')
    pluralize(no_of_days, 'Day')
  end

  def bdsa_references(data)
    return unless data

    references = bdsa_reference_icons.keys.each_with_object({}) { |link, memo| memo[link] = [] }
    data.each do |link|
      type = bdsa_reference_type(link['type'])
      next unless references[type]

      references[type] << link['href']
    end
    references.reject { |_type, links| links.empty? }
  end

  def bdsa_reference_type(type)
    case type
    when 'LINK' then 'OTHER'
    else type
    end
  end

  def bdsa_reference_icons
    { 'ADVISORY' => 'fa-exclamation-circle',
      'VENDOR_UPGRADE' => 'fa-gift',
      'PATCH' => 'fa-road',
      'INTRODUCTORY_COMMIT' => 'fa-share-square',
      'POC' => 'fa-arrow-circle-up',
      'OTHER' => 'fa-list' }
  end

  def cvss_calculator_link(vector)
    version = vector.match(/\d.\d/)
    _cvss_text, vector_info = vector.split("#{version[0]}/")
    "https://nvd.nist.gov/vuln-metrics/cvss/v3-calculator?vector=#{vector_info}&version=#{version[0]}"
  end
end
