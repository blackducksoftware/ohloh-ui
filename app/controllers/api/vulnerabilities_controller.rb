# frozen_string_literal: true

class Api::VulnerabilitiesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :valid_bdsa_id, only: :show

  layout 'vulnerability'

  def index
    @page_title = t('vulnerabilities.bdsa.index.page_title')
    @meta_description = t('vulnerabilities.bdsa.index.meta_description')
    @canonical_url = bdsa_vulnerabilities_url
  end

  def show
    return render 'no_data' unless fetch_bdsa_data

    fetch_cwe
    @cve = fetch_cve
    set_seo_metadata if cookies[:bdsa_cookie_disclaimer]
  end

  def raise_not_found!
    render 'error', status: :not_found
  end

  private

  def fetch_bdsa_data
    url = ENV['BDSA_VULNERABILITY_API'].gsub('BDSA_ID', params[:id].upcase)
    code, @response = Api.get_response(url)
    code == '200' && @response['publishedDate'].to_datetime <= 30.days.ago.to_datetime
  end

  def fetch_cwe
    cwe_urls = @response['_meta']['links'].select { |link| link['rel'] == 'cwe' }
                                          .pluck('href')

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
    render 'no_data' unless params[:id].upcase.match(/^BDSA-(19|[2-9][0-9])\d{2}-\d{4,}$/)
  end

  def set_seo_metadata
    cve_id = extract_cve_id
    suffix = "| #{t('vulnerabilities.bdsa.show.page_title_suffix')}"
    @page_title = if cve_id
                    "#{params[:id].upcase} - #{cve_id} - #{@response['title']} #{suffix}"
                  else
                    "#{params[:id].upcase} - #{@response['title']} #{suffix}"
                  end
    @meta_description = generate_meta_description(cve_id)
    @canonical_url = "#{bdsa_vulnerabilities_url}/#{params[:id].upcase}"
    @cve_id = cve_id
  end

  def extract_cve_id
    return unless @cve_data

    @cve_data['href'].split('/').last
  end

  def generate_meta_description(cve_id = nil)
    description = @response['description'].presence || @response['title']
    description = description.gsub(/<[^>]*>/, '').truncate(140, separator: ' ')
    cvss_score = @response['cvss3']['temporalMetrics']&.dig('score') || @response['cvss3']['baseScore']
    meta_desc = params[:id].upcase.to_s
    meta_desc += " / #{cve_id}" if cve_id
    meta_desc += ": #{description} - CVSS3: #{cvss_score}"
    meta_desc
  end
end
