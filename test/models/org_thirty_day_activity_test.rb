require 'test_helper'

class OrgThirtyDayActivityTest < ActiveSupport::TestCase
  before do
    @org1 = create(:organization, name: 'org_1', url_name: 'org1')
    @org2 = create(:organization, name: 'org_2', url_name: 'org2')
    @org3 = create(:organization, name: 'org_3', url_name: 'org3')
    @org4 = create(:organization, name: 'org_4', url_name: 'org4')
    @org5 = create(:organization, name: 'org_5', url_name: 'org5')

    @ota1 = create(:org_thirty_day_activity, name: 'org_1', url_name: 'org1', organization: @org1,
                                             affiliate_count: 20, thirty_day_commit_count: 200)
    @ota2 = create(:org_thirty_day_activity, name: 'org_2', url_name: 'org2', organization: @org2,
                                             affiliate_count: 20, thirty_day_commit_count: 400)
    @ota3 = create(:org_thirty_day_activity, name: 'org_3', url_name: 'org3', organization: @org3,
                                             affiliate_count: 20, thirty_day_commit_count: 600)
    @ota4 = create(:org_thirty_day_activity, name: 'org_4', url_name: 'org4', organization: @org4,
                                             affiliate_count: 20, thirty_day_commit_count: 800)
    @ota5 = create(:org_thirty_day_activity, name: 'org_5', url_name: 'org5', organization: @org5,
                                             affiliate_count: 20, thirty_day_commit_count: 1000)
  end

  describe 'most_active_orgs' do
    it 'should return top 3 org_thirty_day activities(only with orgs present)' do
      @ota5.update_column(:organization_id, nil)
      most_active_orgs = OrgThirtyDayActivity.most_active_orgs

      most_active_orgs.must_equal [@ota4, @ota3, @ota2]
    end

  end

  describe 'filter_all_orgs' do
    it 'should return org_thirty_day_activities of top 5 orgs(only with orgs present)' do
      @ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.filter_all_orgs.must_equal [@ota4, @ota3, @ota2, @ota1]
    end

    it 'should return org_thirty_day_activities of top 5 orgs(only with thirty_day_commit_count prsent)' do
      @ota5.update_column(:organization_id, @org5.id)
      @ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.filter_all_orgs.must_equal [@ota5, @ota3, @ota2, @ota1]
    end

    it 'should be executed when incorrect method call is made for filtering methods' do
      @ota5.update_column(:organization_id, @org5.id)
      @ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.filter_test.must_equal [@ota5, @ota3, @ota2, @ota1]
    end
  end

  describe 'filter_small_orgs' do
    it 'should return org_thirty_day_activities of top 5 small orgs(only with orgs present)' do
      @ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(project_count: 8)
      OrgThirtyDayActivity.where(id: [@ota2.id, @ota1.id]).update_all(project_count: 12)

      all_orgs = OrgThirtyDayActivity.filter_small_orgs
      all_orgs.must_equal [@ota4, @ota3]
    end

    it 'should return org_thirty_day_activities of top 5 small orgs(only with thirty_day_commit_count prsent)' do
      @ota5.update_column(:organization_id, @org5.id)
      @ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(project_count: 8)
      OrgThirtyDayActivity.where(id: [@ota2.id, @ota1.id]).update_all(project_count: 12)

      all_orgs = OrgThirtyDayActivity.filter_small_orgs
      all_orgs.must_equal [@ota5, @ota3]
    end
  end

  describe 'filter_medium_orgs' do
    it 'should return org_thirty_day_activities of top 5 medium orgs(only with orgs present)' do
      @ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(project_count: 12)
      OrgThirtyDayActivity.where(id: [@ota2.id, @ota1.id]).update_all(project_count: 8)

      all_orgs = OrgThirtyDayActivity.filter_medium_orgs
      all_orgs.must_equal [@ota4, @ota3]
    end

    it 'should return org_thirty_day_activities of top 5 medium orgs(only with thirty_day_commit_count prsent)' do
      @ota5.update_column(:organization_id, @org5.id)
      @ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(project_count: 12)
      OrgThirtyDayActivity.where(id: [@ota2.id, @ota1.id]).update_all(project_count: 8)

      all_orgs = OrgThirtyDayActivity.filter_medium_orgs
      all_orgs.must_equal [@ota5, @ota3]
    end
  end

  describe 'filter_large_orgs' do
    it 'should return org_thirty_day_activities of top 5 large orgs(only with orgs present)' do
      @ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(project_count: 55)
      OrgThirtyDayActivity.where(id: [@ota2.id, @ota1.id]).update_all(project_count: 8)

      all_orgs = OrgThirtyDayActivity.filter_large_orgs
      all_orgs.must_equal [@ota4, @ota3]
    end

    it 'should return org_thirty_day_activities of top 5 large orgs(only with thirty_day_commit_count prsent)' do
      @ota5.update_column(:organization_id, @org5.id)
      @ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(project_count: 55)
      OrgThirtyDayActivity.where(id: [@ota2.id, @ota1.id]).update_all(project_count: 8)

      all_orgs = OrgThirtyDayActivity.filter_large_orgs
      all_orgs.must_equal [@ota5, @ota3]
    end
  end

  describe 'filter_commercial_orgs' do
    it 'should return org_thirty_day_activities of top 5 commercial orgs(only with orgs present)' do
      @ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(org_type: 1)
      OrgThirtyDayActivity.where(id: [@ota2.id, @ota1.id]).update_all(org_type: 2)

      all_orgs = OrgThirtyDayActivity.filter_commercial_orgs
      all_orgs.must_equal [@ota4, @ota3]
    end

    it 'should return org_thirty_day_activities of top 5 commercial orgs(only with thirty_day_commit_count prsent)' do
      @ota5.update_column(:organization_id, @org5.id)
      @ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(org_type: 1)
      OrgThirtyDayActivity.where(id: [@ota2.id, @ota1.id]).update_all(org_type: 2)

      all_orgs = OrgThirtyDayActivity.filter_commercial_orgs
      all_orgs.must_equal [@ota5, @ota3]
    end
  end

  describe 'filter_commercial_orgs' do
    it 'should return org_thirty_day_activities of top 5 educational orgs(only with orgs present)' do
      @ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(org_type: 2)
      OrgThirtyDayActivity.where(id: [@ota2.id, @ota1.id]).update_all(org_type: 1)

      all_orgs = OrgThirtyDayActivity.filter_educational_orgs
      all_orgs.must_equal [@ota4, @ota3]
    end

    it 'should return org_thirty_day_activities of top 5 educational orgs(only with thirty_day_commit_count prsent)' do
      @ota5.update_column(:organization_id, @org5.id)
      @ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(org_type: 2)
      OrgThirtyDayActivity.where(id: [@ota2.id, @ota1.id]).update_all(org_type: 1)

      all_orgs = OrgThirtyDayActivity.filter_educational_orgs
      all_orgs.must_equal [@ota5, @ota3]
    end
  end

  describe 'filter_government_orgs' do
    it 'should return org_thirty_day_activities of top 5 government orgs(only with orgs present)' do
      @ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(org_type: 3)
      OrgThirtyDayActivity.where(id: [@ota2.id, @ota1.id]).update_all(org_type: 1)

      all_orgs = OrgThirtyDayActivity.filter_government_orgs
      all_orgs.must_equal [@ota4, @ota3]
    end

    it 'should return org_thirty_day_activities of top 5 government orgs(only with thirty_day_commit_count prsent)' do
      @ota5.update_column(:organization_id, @org5.id)
      @ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(org_type: 3)
      OrgThirtyDayActivity.where(id: [@ota2.id, @ota1.id]).update_all(org_type: 1)

      all_orgs = OrgThirtyDayActivity.filter_government_orgs
      all_orgs.must_equal [@ota5, @ota3]
    end
  end

  describe 'filter_non_profit_orgs' do
    it 'should return org_thirty_day_activities of top 5 non_profit orgs(only with orgs present)' do
      @ota5.update_column(:organization_id, nil)
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(org_type: 4)
      OrgThirtyDayActivity.where(id: [@ota2.id, @ota1.id]).update_all(org_type: 1)

      all_orgs = OrgThirtyDayActivity.filter_non_profit_orgs
      all_orgs.must_equal [@ota4, @ota3]
    end

    it 'should return org_thirty_day_activities of top 5 non_profit orgs(only with thirty_day_commit_count prsent)' do
      @ota5.update_column(:organization_id, @org5.id)
      @ota4.update_column(:thirty_day_commit_count, nil)
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(org_type: 4)
      OrgThirtyDayActivity.where(id: [@ota2.id, @ota1.id]).update_all(org_type: 1)

      all_orgs = OrgThirtyDayActivity.filter_non_profit_orgs
      all_orgs.must_equal [@ota5, @ota3]
    end
  end
end
