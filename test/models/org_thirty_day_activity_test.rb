# frozen_string_literal: true

require 'test_helper'

class OrgThirtyDayActivityTest < ActiveSupport::TestCase
  (1..5).to_a.each do |value|
    let("org#{value}") { create(:organization, name: "org_#{value}", vanity_url: "org#{value}") }
    let("ota#{value}") do
      create(:org_thirty_day_activity, name: "org_#{value}", vanity_url: "org#{value}",
                                       organization: send("org#{value}"), affiliate_count: 20,
                                       thirty_day_commit_count: 200 * value)
    end
  end

  before do
    (1..5).to_a.each do |value|
      ota = send("ota#{value}")
      send("org#{value}").update_column(:thirty_day_activity_id, ota.id)
    end
  end

  describe 'most_active_orgs' do
    it 'should return most active orgs thirty day activities' do
      ota5.update_column(:organization_id, nil)
      most_active_orgs = OrgThirtyDayActivity.most_active_orgs

      most_active_orgs.map(&:name).must_equal [ota4.name, ota3.name, ota2.name]
    end
  end

  describe 'filter_all_orgs' do
    it 'should return org_thirty_day_activities of top 5 orgs(only with orgs present)' do
      ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.filter_all_orgs.must_equal [ota4, ota3, ota2, ota1]
    end

    it 'should return org_thirty_day_activities of top 5 orgs(only with thirty_day_commit_count prsent)' do
      ota5.update_column(:organization_id, org5.id)
      ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.filter_all_orgs.must_equal [ota5, ota3, ota2, ota1]
    end
  end

  describe 'filter_small_orgs' do
    it 'should return org_thirty_day_activities of top 5 small orgs(only with orgs present)' do
      ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(project_count: 8)
      OrgThirtyDayActivity.where(id: [ota2.id, ota1.id]).update_all(project_count: 12)

      all_orgs = OrgThirtyDayActivity.filter_small_orgs
      all_orgs.must_equal [ota4, ota3]
    end

    it 'should return org_thirty_day_activities of top 5 small orgs(only with thirty_day_commit_count prsent)' do
      ota5.update_column(:organization_id, org5.id)
      ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(project_count: 8)
      OrgThirtyDayActivity.where(id: [ota2.id, ota1.id]).update_all(project_count: 12)

      all_orgs = OrgThirtyDayActivity.filter_small_orgs
      all_orgs.must_equal [ota5, ota3]
    end
  end

  describe 'filter_medium_orgs' do
    it 'should return org_thirty_day_activities of top 5 medium orgs(only with orgs present)' do
      ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(project_count: 12)
      OrgThirtyDayActivity.where(id: [ota2.id, ota1.id]).update_all(project_count: 8)

      all_orgs = OrgThirtyDayActivity.filter_medium_orgs
      all_orgs.must_equal [ota4, ota3]
    end

    it 'should return org_thirty_day_activities of top 5 medium orgs(only with thirty_day_commit_count prsent)' do
      ota5.update_column(:organization_id, org5.id)
      ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(project_count: 12)
      OrgThirtyDayActivity.where(id: [ota2.id, ota1.id]).update_all(project_count: 8)

      all_orgs = OrgThirtyDayActivity.filter_medium_orgs
      all_orgs.must_equal [ota5, ota3]
    end
  end

  describe 'filter_large_orgs' do
    it 'should return org_thirty_day_activities of top 5 large orgs(only with orgs present)' do
      ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(project_count: 55)
      OrgThirtyDayActivity.where(id: [ota2.id, ota1.id]).update_all(project_count: 8)

      all_orgs = OrgThirtyDayActivity.filter_large_orgs
      all_orgs.must_equal [ota4, ota3]
    end

    it 'should return org_thirty_day_activities of top 5 large orgs(only with thirty_day_commit_count prsent)' do
      ota5.update_column(:organization_id, org5.id)
      ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(project_count: 55)
      OrgThirtyDayActivity.where(id: [ota2.id, ota1.id]).update_all(project_count: 8)

      all_orgs = OrgThirtyDayActivity.filter_large_orgs
      all_orgs.must_equal [ota5, ota3]
    end
  end

  describe 'filter_commercial_orgs' do
    it 'should return org_thirty_day_activities of top 5 commercial orgs(only with orgs present)' do
      ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(org_type: 1)
      OrgThirtyDayActivity.where(id: [ota2.id, ota1.id]).update_all(org_type: 2)

      all_orgs = OrgThirtyDayActivity.filter_commercial_orgs
      all_orgs.must_equal [ota4, ota3]
    end

    it 'should return org_thirty_day_activities of top 5 commercial orgs(only with thirty_day_commit_count prsent)' do
      ota5.update_column(:organization_id, org5.id)
      ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(org_type: 1)
      OrgThirtyDayActivity.where(id: [ota2.id, ota1.id]).update_all(org_type: 2)

      all_orgs = OrgThirtyDayActivity.filter_commercial_orgs
      all_orgs.must_equal [ota5, ota3]
    end
  end

  describe 'filter_commercial_orgs' do
    it 'should return org_thirty_day_activities of top 5 educational orgs(only with orgs present)' do
      ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(org_type: 2)
      OrgThirtyDayActivity.where(id: [ota2.id, ota1.id]).update_all(org_type: 1)

      all_orgs = OrgThirtyDayActivity.filter_educational_orgs
      all_orgs.must_equal [ota4, ota3]
    end

    it 'should return org_thirty_day_activities of top 5 educational orgs(only with thirty_day_commit_count prsent)' do
      ota5.update_column(:organization_id, org5.id)
      ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(org_type: 2)
      OrgThirtyDayActivity.where(id: [ota2.id, ota1.id]).update_all(org_type: 1)

      all_orgs = OrgThirtyDayActivity.filter_educational_orgs
      all_orgs.must_equal [ota5, ota3]
    end
  end

  describe 'filter_government_orgs' do
    it 'should return org_thirty_day_activities of top 5 government orgs(only with orgs present)' do
      ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(org_type: 3)
      OrgThirtyDayActivity.where(id: [ota2.id, ota1.id]).update_all(org_type: 1)

      all_orgs = OrgThirtyDayActivity.filter_government_orgs
      all_orgs.must_equal [ota4, ota3]
    end

    it 'should return org_thirty_day_activities of top 5 government orgs(only with thirty_day_commit_count prsent)' do
      ota5.update_column(:organization_id, org5.id)
      ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(org_type: 3)
      OrgThirtyDayActivity.where(id: [ota2.id, ota1.id]).update_all(org_type: 1)

      all_orgs = OrgThirtyDayActivity.filter_government_orgs
      all_orgs.must_equal [ota5, ota3]
    end
  end

  describe 'filter_non_profit_orgs' do
    it 'should return org_thirty_day_activities of top 5 non_profit orgs(only with orgs present)' do
      ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(org_type: 4)
      OrgThirtyDayActivity.where(id: [ota2.id, ota1.id]).update_all(org_type: 1)

      all_orgs = OrgThirtyDayActivity.filter_non_profit_orgs
      all_orgs.must_equal [ota4, ota3]
    end

    it 'should return org_thirty_day_activities of top 5 non_profit orgs(only with thirty_day_commit_count prsent)' do
      ota5.update_column(:organization_id, org5.id)
      ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(org_type: 4)
      OrgThirtyDayActivity.where(id: [ota2.id, ota1.id]).update_all(org_type: 1)

      all_orgs = OrgThirtyDayActivity.filter_non_profit_orgs
      all_orgs.must_equal [ota5, ota3]
    end
  end

  describe 'filter' do
    it 'should call the correct filter method when filter is all_orgs' do
      OrgThirtyDayActivity.expects(:filter_all_orgs).once
      OrgThirtyDayActivity.filter('all_orgs')
    end

    it 'should call the correct filter method when filter is large' do
      OrgThirtyDayActivity.expects(:filter_large_orgs).once
      OrgThirtyDayActivity.filter('large')
    end

    it 'should call the correct filter method when filter is small' do
      OrgThirtyDayActivity.expects(:filter_small_orgs).once
      OrgThirtyDayActivity.filter('small')
    end

    it 'should call the correct filter method when filter is medium' do
      OrgThirtyDayActivity.expects(:filter_medium_orgs).once
      OrgThirtyDayActivity.filter('medium')
    end

    it 'should call the correct filter method when filter is government' do
      OrgThirtyDayActivity.expects(:filter_government_orgs).once
      OrgThirtyDayActivity.filter('government')
    end

    it 'should call the correct filter method when filter is commercial' do
      OrgThirtyDayActivity.expects(:filter_commercial_orgs).once
      OrgThirtyDayActivity.filter('commercial')
    end

    it 'should call the correct filter method when filter is non_profit' do
      OrgThirtyDayActivity.expects(:filter_non_profit_orgs).once
      OrgThirtyDayActivity.filter('non_profit')
    end

    it 'should call the correct filter method when filter is educational' do
      OrgThirtyDayActivity.expects(:filter_educational_orgs).once
      OrgThirtyDayActivity.filter('educational')
    end

    it 'should call the correct filter method when filter is unsupported' do
      OrgThirtyDayActivity.expects(:filter_all_orgs).once
      OrgThirtyDayActivity.filter('i_am_a_banana')
    end
  end
end
