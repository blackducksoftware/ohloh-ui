# frozen_string_literal: true

class Api::VulnerabilitiesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :valid_bdsa_id, only: :show

  layout 'vulnerability'

  def show
    url = ENV['BDSA_VULNERABILITY_API'].gsub('BDSA_ID', params[:id].upcase)
    code, @response = Api.get_response(url)
    return render 'no_data' if code != '200' || @response['publishedDate'].to_datetime > 30.days.ago.to_datetime

    fetch_cwe
    @cve = fetch_cve
  end

  def raise_not_found!
    render 'error', status: :not_found
  end

  private

  def fetch_cwe
    cwe_urls = @response['_meta']['links'].select { |link| link['rel'] == 'cwe' }
                                          .collect { |link| link['href'] }

    return unless cwe_urls

    @cwe_data = []
    cwe_urls.each do |cwe_url|
      code, response = Api.get_response(cwe_url)
      @cwe_data << [cwe_url.split('/').last, response['name'], response['description']] if code == '200'
    end
  end

  def fetch_cve
    @cve_data = @response['_meta']['links'].select { |link| link['rel'] == 'cve' }[0]

    return unless @cve_data

    code, response = Api.get_response(@cve_data['href'])
    response['cvss3'] if code == '200'
  end

  def valid_bdsa_id
    return render 'no_data' unless params[:id].upcase.match(/^BDSA-(19|[2-9][0-9])\d{2}-\d{4}$/)
  end
end
