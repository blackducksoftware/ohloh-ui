# frozen_string_literal: true

require 'test_helper'

class Api::VulnerabilitiesControllerTest < ActionDispatch::IntegrationTest
  it 'must render the BDSA page' do
    VCR.use_cassette('vulnerabilities') do
      get '/vulnerabilities/bdsa/1'
      assert_response :success
      _(response.body).must_match 'Severity'
      _(response.body).must_match 'CVE'
      _(response.body).wont_match 'References'
    end
  end

  it 'must not render if unsuccessful' do
    VCR.use_cassette('vulnerabilities') do
      get '/vulnerabilities/bdsa/2'
      assert_response :success
      _(response.body).must_match 'No matching results found'
    end
  end

  it 'must render error page for unmatched vulnerabilities routes' do
    get '/vulnerabilities/bdsa'
    assert_response :not_found
    assert_template 'error'
  end

  it 'must render page without CVE' do
    VCR.use_cassette('vulnerabilities') do
      get '/vulnerabilities/bdsa/2'
      assert_response :success
      _(response.body).wont_match 'CVE'
    end
  end

  it 'must render page along with references' do
    VCR.use_cassette('vulnerabilities') do
      get '/vulnerabilities/bdsa/3'
      assert_response :success
      _(response.body).must_match 'References'
    end
  end
end
