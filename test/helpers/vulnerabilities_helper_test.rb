# frozen_string_literal: true

require 'test_helper'

class VulnerabilitiesHelperTest < ActionView::TestCase
  include VulnerabilitiesHelper

  describe 'major releases' do
    it 'should correctly filter version releases' do
      project = FactoryBot.create(:project)
      pss = FactoryBot.create(:project_security_set, project: project)
      FactoryBot.create_list(:major_release_one, 10, project_security_set: pss)
      FactoryBot.create_list(:major_release_two, 10, project_security_set: pss)
      FactoryBot.create_list(:major_release_three, 10, project_security_set: pss)
      FactoryBot.create(:release, version: '10.1')
      FactoryBot.create(:release, version: '21.1')
      FactoryBot.create(:release, version: '32.1')
      major_releases(Release.all, project).must_equal [1, 2, 3, 10, 21, 32]
    end

    it 'should correctly filter android version releases' do
      android = FactoryBot.create(:project, vanity_url: 'android')
      pss = FactoryBot.create(:project_security_set, project: android)
      FactoryBot.create(:major_release_one, version: 'android-5.0.0_r1', project_security_set: pss)
      FactoryBot.create(:major_release_two, version: 'android-2.0.5_r1', project_security_set: pss)
      FactoryBot.create(:major_release_three, version: 'android-3.1.0_r1', project_security_set: pss)
      major_releases(Release.all, android).must_equal ['android-5.0.0_r1', 'android-2.0.5_r1', 'android-3.1.0_r1']
    end
  end
end
