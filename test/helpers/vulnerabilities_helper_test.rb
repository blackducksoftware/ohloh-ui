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
      _(major_releases(Release.all, project)).must_equal [1, 2, 3, 10, 21, 32]
    end

    it 'should correctly include v?\.? version releases' do
      project = FactoryBot.create(:project)
      pss = FactoryBot.create(:project_security_set, project: project)
      FactoryBot.create_list(:major_release_one, 10, project_security_set: pss)
      FactoryBot.create_list(:major_release_two, 10, project_security_set: pss)
      FactoryBot.create_list(:major_release_three, 10, project_security_set: pss)
      FactoryBot.create(:release, version: 'v11.1.1')
      FactoryBot.create(:release, version: 'v.22.1.1')
      FactoryBot.create(:release, version: 'v32.1.2.2')
      _(major_releases(Release.all, project)).must_equal [1, 2, 3, 11, 22, 32]
    end

    it 'should correctly filter android version releases' do
      android = FactoryBot.create(:project, vanity_url: 'android')
      pss = FactoryBot.create(:project_security_set, project: android)
      FactoryBot.create(:major_release_one, version: 'android-5.0.0_r1', project_security_set: pss)
      FactoryBot.create(:major_release_two, version: 'android-2.0.5_r1', project_security_set: pss)
      FactoryBot.create(:major_release_three, version: 'android-3.1.0_r1', project_security_set: pss)
      _(major_releases(Release.all, android)).must_equal ['android-5.0.0_r1', 'android-2.0.5_r1', 'android-3.1.0_r1']
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
      _(sort_releases_by_version_number(Release.all)).must_equal [rel3, rel2, rel1, rel4]
    end

    it 'should correctly filter v include version releases' do
      project = FactoryBot.create(:project)
      FactoryBot.create(:project_security_set, project: project)
      rel1 = FactoryBot.create(:release, version: 'v10.1.1')
      rel2 = FactoryBot.create(:release, version: 'v.1.1.2')
      rel3 = FactoryBot.create(:release, version: 'v10.1.3')
      rel4 = FactoryBot.create(:release, version: 'v.10.1')
      _(sort_releases_by_version_number(Release.all)).must_equal [rel3, rel1, rel4, rel2]
    end

    it 'should correctly filter version releases w/ alphabetic chars' do
      project = FactoryBot.create(:project)
      FactoryBot.create(:project_security_set, project: project)
      rel1 = FactoryBot.create(:release, version: 'PRE_RELEASE')
      rel2 = FactoryBot.create(:release, version: 'ALPHA_RELEASE')
      rel3 = FactoryBot.create(:release, version: 'BETA_RELEASE')
      _(sort_releases_by_version_number(Release.all)).must_equal [rel2, rel3, rel1]
    end

    it 'should correctly filter android version releases' do
      android = FactoryBot.create(:project, vanity_url: 'android')
      pss = FactoryBot.create(:project_security_set, project: android)
      rel1 = FactoryBot.create(:major_release_one, version: 'android-5.0.0_r1', project_security_set: pss)
      rel2 = FactoryBot.create(:major_release_two, version: 'android-2.0.5_r1', project_security_set: pss)
      rel3 = FactoryBot.create(:major_release_three, version: 'android-3.1.0_r1', project_security_set: pss)
      _(sort_releases_by_version_number(Release.all)).must_equal [rel1, rel3, rel2]
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
      _(sort_releases_by_version_number(Release.all)).must_equal [rel7, rel6, rel5, rel4, rel3, rel2, rel1]
    end

    it 'should correctly filter invalid names of version releases' do
      project = FactoryBot.create(:project)
      FactoryBot.create(:project_security_set, project: project)
      rel1 = FactoryBot.create(:release, version: 'Compose.NET 0.4b')
      rel2 = FactoryBot.create(:release, version: 'Compose.NET 0.3b')
      rel3 = FactoryBot.create(:release, version: 'Compose-.NET 0.8 for .NET 1.1')
      rel4 = FactoryBot.create(:release, version: 'Compose-.NET 0.8.1 for .NET 1.1')
      rel5 = FactoryBot.create(:release, version: 'Compose*.NET 0.7b')
      _(sort_releases_by_version_number(Release.all)).must_equal [rel4, rel3, rel5, rel1, rel2]
    end

    # rubocop: disable Metrics/LineLength
    it 'should correctly filter a mix of valid and invalid version release names' do
      project = FactoryBot.create(:project)
      FactoryBot.create(:project_security_set, project: project)
      rel1 = FactoryBot.create(:release, version: 'N/A')
      rel2 = FactoryBot.create(:release, version: 'BEEing_5.0.3')
      rel3 = FactoryBot.create(:release, version: 'BEEingXLib_7.0.0')
      rel4 = FactoryBot.create(:release, version: 'BEEingLib_5.0.0')
      rel5 = FactoryBot.create(:release, version: 'Sources')
      rel6 = FactoryBot.create(:release, version: '3.0.0.5')
      rel7 = FactoryBot.create(:release, version: '2.1.3')
      rel8 = FactoryBot.create(:release, version: '3.0.0')
      rel9 = FactoryBot.create(:release, version: 'Navicat BEEing Databases')
      rel10 = FactoryBot.create(:release, version: 'BEEingDependencies')
      rel11 = FactoryBot.create(:release, version: 'BEEingLibs')
      _(sort_releases_by_version_number(Release.all)).must_equal [rel6, rel8, rel7, rel10, rel4, rel11, rel3, rel2, rel1, rel9, rel5]
    end
    # rubocop: enable Metrics/LineLength
  end
end
