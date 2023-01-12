# frozen_string_literal: true

class Api::VulnerabilitiesController < ApplicationController
  skip_before_action :verify_authenticity_token

  layout 'vulnerability'

  def show
    url = ENV['BDSA_VULNERABILITY_API'].gsub('BDSA_ID', params[:id])
    code, @response = Api.get_response(url)
    return render 'no_data' if code != '200' || @response['publishedDate'].to_datetime > 30.days.ago.to_datetime

    @cwe = fetch_cwe
  end

  def raise_not_found!
    render 'error', status: :not_found
  end

  private

  def fetch_cwe
    url = ENV['KB_CWE_API'].gsub('CWE_ID', cwe_id)
    code, response = Api.get_response(url)
    [response['name'], response['description']] if code == '200'
  end

  def cwe_id
    @response['_meta']['links'].select { |c| c['rel'] == 'cwe' }[0]['href'].split('/').last
  end
end
