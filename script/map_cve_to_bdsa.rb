#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

class MapCveToBdsa
  def execute
    Vulnerability.where('cve_id like ?', 'CVE%').select('cve_id').distinct.each do |vuln|
      url = ENV['CVE_VULNERABILITY_API'] + vuln.cve_id
      code, response = Api.get_response(url)
      next unless code == '200'

      create_cve_bdsa_record(response, vuln.cve_id)
    end
  end

  private

  def create_cve_bdsa_record(data, cve_id)
    data['_meta']['links'].select { |link| link['rel'] == 'bdsa' }.each do |bdsa_url|
      bdsa_id = bdsa_url['href'].split('/').last
      CveBdsa.where(cve_id: cve_id, bdsa_id: bdsa_id).first_or_create
    end
  end
end
