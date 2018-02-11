require 'test_helper'

class ApiJobTest < ActiveSupport::TestCase
  it 'should get the jobs for a given project_id' do
    VCR.use_cassette('project_jobs') do
      api = ApiJob.new(1, 1).get
      assert JSON.parse(api)['entries'].length < 20
    end
  end
end
