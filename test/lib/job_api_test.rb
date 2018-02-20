require 'test_helper'

class JobApiTest < ActiveSupport::TestCase
  it 'should get the jobs for a given project_id' do
    VCR.use_cassette('project_jobs') do
      api = JobApi.new(1, 1).fetch
      assert JSON.parse(api)['entries'].length < 20
    end
  end
end
