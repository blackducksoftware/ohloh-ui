require 'test_helper'
class ProjectSecurityScoreTest < ActiveSupport::TestCase
  it 'should return pvs, pss when valid UUID is passed with UUID' do
    VCR.use_cassette('kb_project_vulnerability_details') do
      pss = ProjectSecurityScore.new('69cf83da-59d7-4fae-ba34-0c27a5b8031e')
      pss.pvs.must_equal 813.015
      pss.pss.must_equal 84.324
    end
  end
  it 'should return no_uuid when UUID is not passed to the request' do
    pss = ProjectSecurityScore.new('')
    pss.errors.must_include(:no_uuid)
  end
  it 'should return http_error when invalid uuid is  passed' do
    VCR.use_cassette('kb_project_404') do
      pss = ProjectSecurityScore.new('c2ac3ddc-527f-4c18-91ea-8cb8855bf4a2')
      pss.errors.must_include(:http_error)
    end
  end
  it 'should return empty data when valid uuid is passed' do
    VCR.use_cassette('kb_empty_project') do
      pss = ProjectSecurityScore.new('1234')
      pss.errors.must_include(:no_data)
    end
  end
end
