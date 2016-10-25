require 'test_helper'

class VulnerabilitiesHelperTest < ActionView::TestCase
  include VulnerabilitiesHelper

  describe 'major releases' do
    it 'should correctly filter version releases' do
      project = FactoryGirl.create(:project)
      pss = FactoryGirl.create(:project_security_set, project: project)
      FactoryGirl.create_list(:major_release_one, 10, project_security_set: pss)
      FactoryGirl.create_list(:major_release_two, 10, project_security_set: pss)
      FactoryGirl.create_list(:major_release_three, 10, project_security_set: pss)
      FactoryGirl.create(:release, version: '10.1')
      FactoryGirl.create(:release, version: '21.1')
      FactoryGirl.create(:release, version: '32.1')
      major_releases(Release.all, project).must_equal [1, 2, 3, 10, 21, 32]
    end

    it 'should correctly filter android version releases' do
      android = FactoryGirl.create(:project, vanity_url: 'android')
      pss = FactoryGirl.create(:project_security_set, project: android)
      FactoryGirl.create(:major_release_one, version: 'android-5.0.0_r1', project_security_set: pss)
      FactoryGirl.create(:major_release_two, version: 'android-2.0.5_r1', project_security_set: pss)
      FactoryGirl.create(:major_release_three, version: 'android-3.1.0_r1', project_security_set: pss)
      major_releases(Release.all, android).must_equal ['android-5.0.0_r1', 'android-2.0.5_r1', 'android-3.1.0_r1']
    end
  end
end
