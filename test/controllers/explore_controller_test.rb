require 'test_helper'

describe 'ExploreController' do
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
    @stat1 = create(:org_stats_by_sector)
    @stat2 = create(:org_stats_by_sector, org_type: 2, organization_count: 20)
    @stat3 = create(:org_stats_by_sector, org_type: 3, organization_count: 40)
    @stat4 = create(:org_stats_by_sector, org_type: 4, organization_count: 50)
  end

  describe 'orgs' do
    it 'should respond with the necessary data when filter is all' do
      get 'orgs', filter: 'all'

      must_respond_with :ok
      assigns(:newest_orgs).must_equal [@org5, @org4, @org3]
      assigns(:most_active_orgs).must_equal [@ota5, @ota4, @ota3]
      assigns(:stats_by_sector).must_equal [@stat4, @stat3, @stat2, @stat1]
      assigns(:org_by_30_day_commits).must_equal [@ota5, @ota4, @ota3, @ota2, @ota1]
    end

    it 'should respond with the necessary data when filter is government' do
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(org_type: 3)
      get 'orgs', filter: 'government'

      must_respond_with :ok
      assigns(:newest_orgs).must_equal [@org5, @org4, @org3]
      assigns(:most_active_orgs).must_equal [@ota5, @ota4, @ota3]
      assigns(:stats_by_sector).must_equal [@stat4, @stat3, @stat2, @stat1]
      assigns(:org_by_30_day_commits).must_equal [@ota5, @ota4, @ota3]
    end

    it 'should respond with the necessary data when filter is none' do
      get 'orgs'

      must_respond_with :ok
      assigns(:newest_orgs).must_equal [@org5, @org4, @org3]
      assigns(:most_active_orgs).must_equal [@ota5, @ota4, @ota3]
      assigns(:stats_by_sector).must_equal [@stat4, @stat3, @stat2, @stat1]
      assigns(:org_by_30_day_commits).must_equal [@ota5, @ota4, @ota3, @ota2, @ota1]
    end
  end

  describe 'orgs_by_thirty_day_commit_volume' do
    it 'should return json of filtered record when filter is none' do
      get :orgs_by_thirty_day_commit_volume
      result = JSON.parse(response.body)

      must_respond_with :ok
      result['orgs'].first['name'].must_equal @ota5.name
      result['orgs'].second['name'].must_equal @ota4.name
      result['orgs'].third['name'].must_equal @ota3.name
      result['orgs'].fourth['name'].must_equal @ota2.name
      result['orgs'].fifth['name'].must_equal @ota1.name
    end

    it 'should return json of filtered record when filter is government' do
      OrgThirtyDayActivity.where(id: [@ota5.id, @ota4.id, @ota3.id]).update_all(org_type: 3)
      get :orgs_by_thirty_day_commit_volume, filter: 'government'
      result = JSON.parse(response.body)

      must_respond_with :ok
      result['orgs'].first['name'].must_equal @ota5.name
      result['orgs'].second['name'].must_equal @ota4.name
      result['orgs'].third['name'].must_equal @ota3.name
    end

    it 'should return json of filtered record when filter is all' do
      get :orgs_by_thirty_day_commit_volume, filter: 'all'
      result = JSON.parse(response.body)

      must_respond_with :ok
      result['orgs'].first['name'].must_equal @ota5.name
      result['orgs'].second['name'].must_equal @ota4.name
      result['orgs'].third['name'].must_equal @ota3.name
      result['orgs'].fourth['name'].must_equal @ota2.name
      result['orgs'].fifth['name'].must_equal @ota1.name
    end
  end
end
