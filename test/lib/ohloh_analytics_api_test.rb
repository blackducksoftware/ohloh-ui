# frozen_string_literal: true

require 'test_helper'

class OhlohAnalyticsApiTest < ActiveSupport::TestCase
  let(:project) { create(:project, id: 1, name: 'Testing', description: 'This is test project') }

  it 'must raise error when the api throws an exception' do
    Net::HTTP.stubs(:get_response).returns(Net::HTTPServerError.new('1', '503', 'error'))
    Net::HTTPServerError.any_instance.stubs(:body).returns('')
    path = 'api/v1/jobs/project_jobs'
    _(-> { OhlohAnalyticsApi.get_response(path) }).must_raise(OhlohAnalyticsError)
  end

  it 'must return true when attributes are valid' do
    path = 'api/v1/jobs/project_jobs'
    VCR.use_cassette('project_jobs', match_requests_on: [:path]) do
      _(OhlohAnalyticsApi.get_response(path, id: project.id, page: 1)).wont_be_empty
    end
  end
end
