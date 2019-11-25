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

  describe '' do
    it 'should correctly filter version releases' do
      project = FactoryBot.create(:project)
      FactoryBot.create(:project_security_set, project: project)
      rel1 = FactoryBot.create(:release, version: '10.1.1')
      rel2 = FactoryBot.create(:release, version: '10.1.2')
      rel3 = FactoryBot.create(:release, version: '10.1.3')
      rel4 = FactoryBot.create(:release, version: '10.1')
      sort_releases_by_version_number(Release.all).must_equal [rel3, rel2, rel1, rel4]
    end

    it 'should correctly filter version releases w/ alphabetic chars' do
      project = FactoryBot.create(:project)
      FactoryBot.create(:project_security_set, project: project)
      rel1 = FactoryBot.create(:release, version: 'PRE_RELEASE')
      rel2 = FactoryBot.create(:release, version: 'ALPHA_RELEASE')
      rel3 = FactoryBot.create(:release, version: 'BETA_RELEASE')
      sort_releases_by_version_number(Release.all).must_equal [rel2, rel3, rel1]
    end

    it 'should correctly filter android version releases' do
      android = FactoryBot.create(:project, vanity_url: 'android')
      pss = FactoryBot.create(:project_security_set, project: android)
      rel1 = FactoryBot.create(:major_release_one, version: 'android-5.0.0_r1', project_security_set: pss)
      rel2 = FactoryBot.create(:major_release_two, version: 'android-2.0.5_r1', project_security_set: pss)
      rel3 = FactoryBot.create(:major_release_three, version: 'android-3.1.0_r1', project_security_set: pss)
      sort_releases_by_version_number(Release.all).must_equal [rel1, rel3, rel2]
    end

    it 'should correctly filter mixed style of version releases' do
      project = FactoryBot.create(:project)
      FactoryBot.create(:project_security_set, project: project)
      rel1 = FactoryBot.create(:release, version: '1.0.0-alpha')
      rel2 = FactoryBot.create(:release, version: '1.0.0-alpha.1')
      rel3 = FactoryBot.create(:release, version: '1.0.0-beta')
      rel4 = FactoryBot.create(:release, version: '1.0.0-beta.2')
      rel5 = FactoryBot.create(:release, version: '1.0.0-beta.11')
      rel6 = FactoryBot.create(:release, version: '1.0.0-rc.1')
      rel7 = FactoryBot.create(:release, version: '1.0.0')
      sort_releases_by_version_number(Release.all).must_equal [rel7, rel6, rel5, rel4, rel3, rel2, rel1]
    end
  end
end
