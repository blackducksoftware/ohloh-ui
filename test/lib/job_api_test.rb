require 'test_helper'

class JobApiTest < ActiveSupport::TestCase
  it 'should get the jobs for a given project_id' do
    VCR.use_cassette('project_jobs', match_requests_on: [:path]) do
      api = JobApi.new(id: 1, page: 1).fetch
      assert JSON.parse(api)['entries'].length < 20
    end
  end
end
