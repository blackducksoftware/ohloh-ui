require 'test_helper'
describe 'ProjectSecurityScore' do
  describe 'get_pvs_pss' do
    it 'should return array of pvs, pss when valid UUID is passed with UUID' do
      VCR.use_cassette('kb_project_vulnerability_details') do
        array = ProjectSecurityScore.get_pvs_pss('69cf83da-59d7-4fae-ba34-0c27a5b8031e')
        array.first.must_equal 884.58
        array.last.must_equal 82.703
      end
    end
    it 'should return no_uuid when UUID is not passed' do
      array = ProjectSecurityScore.get_pvs_pss('')
      array.must_equal ['no_uuid', 'no_uuid']
    end
    it 'should return no_uuid when UUID is not passed' do
      VCR.use_cassette('kb_project_404') do
        array = ProjectSecurityScore.get_pvs_pss('c2ac3ddc-527f-4c18-91ea-8cb8855bf4a2')
        array.must_equal ['HTTP_404_Error', 'HTTP_404_Error']
      end
    end

  end
end