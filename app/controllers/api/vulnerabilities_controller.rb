# frozen_string_literal: true

class Api::VulnerabilitiesController < ApplicationController
  skip_before_action :verify_authenticity_token

  layout 'vulnerability'

  def show
    url = ENV['BDSA_VULNERABILITY_API'].gsub('BDSA_ID', params[:id])
    code, @response = Api.get_response(url)
    return render 'no_data' if code != '200' || @response['publishedDate'].to_datetime > 30.days.ago.to_datetime

    @cwe = fetch_cwe

    @cve = fetch_cve
  end

  def raise_not_found!
    render 'error', status: :not_found
  end

  private

  def fetch_cwe
    cwe_data = @response['_meta']['links'].select { |link| link['rel'] == 'cwe' }[0]

    return unless cwe_data

    cwe_id = cwe_data['href'].split('/').last
    code, response = Api.get_response(cwe_data['href'])
    [cwe_id, response['name'], response['description']] if code == '200'
  end

  def fetch_cve
    @cve_data = @response['_meta']['links'].select { |link| link['rel'] == 'cve' }[0]

    return unless @cve_data

    code, response = Api.get_response(@cve_data['href'])
    response['cvss3'] if code == '200'
  end
end
