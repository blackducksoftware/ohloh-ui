require 'test_helper'

class CodeLocationApiTest < ActiveSupport::TestCase
  it 'should get the jobs for a given project_id' do
    VCR.use_cassette('code_location_find_by_url') do
      api = CodeLocationApi.new(url: 'git://github.com/rails/rails.git', branch: 'master').fetch
      assert JSON.parse(api).first['id'], 11
    end
  end
end
