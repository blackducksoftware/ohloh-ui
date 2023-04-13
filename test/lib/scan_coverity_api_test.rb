# frozen_string_literal: true

require 'test_helper'

class ScanCoverityApiTest < ActiveSupport::TestCase
  it 'must return true when attributes are valid' do
    path = 'api/projects'
    data = { name: 'Dummytestdata', repo_url: 'https://github.com/rails/rails',
             user_id: 'e1dc08285095f4ff99199c3436532768', language: 'JAVA' }
    VCR.use_cassette('scan_projects', match_requests_on: [:path]) do
      _(ScanCoverityApi.save(path, data)).wont_be_empty
    end
  end

  it 'must return false when attributes are invalid' do
    path = 'api/projects'
    data = { name: 'Dummytestdata', repo_url: 'https://github.com/rails/rails',
             user_id: 'e1dc08285095f4ff99199c3436532768' }
    VCR.use_cassette('scan_projects_error', match_requests_on: [:path]) do
      _(ScanCoverityApi.save(path, data)).must_equal false
    end
  end

  it 'must raise error when the api throws an exception' do
    Net::HTTP.stubs(:get_response).returns(Net::HTTPServerError.new('1', '503', 'error'))
    Net::HTTPServerError.any_instance.stubs(:body).returns('')
    path = 'api/projects'
    _(-> { ScanCoverityApi.get_response(path) }).must_raise(ScanCoverityApiError)
  end
end
