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

    data = data.select { |link| %w[ADVISORY VENDOR_UPGRADE PATCH].include?(link['type']) }
    references = { 'ADVISORY' => [], 'VENDOR_UPGRADE' => [], 'PATCH' => [] }
    data.each { |link| references[link['type']] << link['href'] }
    references.reject { |_type, links| links.empty? }
  end

  def bdsa_reference_icon(type)
    icons = { 'ADVISORY' => 'fa-exclamation-circle',
              'VENDOR_UPGRADE' => 'fa-gift',
              'PATCH' => 'fa-connectdevelop' }
    icons[type]
  end
end
