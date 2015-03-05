require 'test_helper'

describe 'ExploreController' do
  (1..5).to_a.each do |value|
    let("org#{value}") { create(:organization, name: "org_#{value}", url_name: "org#{value}") }
    let("ota#{value}") do
      create(:org_thirty_day_activity, name: "org_#{value}", url_name: "org#{value}",
                                       organization: send("org#{value}"), affiliate_count: 20,
                                       thirty_day_commit_count: 200 * value)
    end
  end

  before do
    @stat1 = create(:org_stats_by_sector)
    @stat2 = create(:org_stats_by_sector, org_type: 2, organization_count: 20)
    @stat3 = create(:org_stats_by_sector, org_type: 3, organization_count: 40)
    @stat4 = create(:org_stats_by_sector, org_type: 4, organization_count: 50)

    (1..5).to_a.each do |value|
      ota = send("ota#{value}")
      send("org#{value}").update_column(:thirty_day_activity_id, ota.id)
    end
  end

  describe 'orgs' do
    it 'should respond with the necessary data when filter is all' do
      get :orgs, filter: 'all'

      must_respond_with :ok
      assigns(:newest_orgs).must_equal [org5, org4, org3]
      assigns(:most_active_orgs).map(&:name).must_equal [ota5.name, ota4.name, ota3.name]
      assigns(:stats_by_sector).must_equal [@stat4, @stat3, @stat2, @stat1]
      assigns(:org_by_30_day_commits).must_equal [ota5, ota4, ota3, ota2, ota1]
    end

    it 'should respond with the necessary data when filter is government' do
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(org_type: 3)
      get :orgs, filter: 'government'

      must_respond_with :ok
      assigns(:newest_orgs).must_equal [org5, org4, org3]
      assigns(:most_active_orgs).map(&:name).must_equal [ota5.name, ota4.name, ota3.name]
      assigns(:stats_by_sector).must_equal [@stat4, @stat3, @stat2, @stat1]
      assigns(:org_by_30_day_commits).must_equal [ota5, ota4, ota3]
    end

    it 'should respond with the necessary data when filter is none' do
      get :orgs

      must_respond_with :ok
      assigns(:newest_orgs).must_equal [org5, org4, org3]
      assigns(:most_active_orgs).map(&:name).must_equal [ota5.name, ota4.name, ota3.name]
      assigns(:stats_by_sector).must_equal [@stat4, @stat3, @stat2, @stat1]
      assigns(:org_by_30_day_commits).must_equal [ota5, ota4, ota3, ota2, ota1]
    end
  end

  describe 'orgs_by_thirty_day_commit_volume' do
    it 'should return json of filtered record when filter is none' do
      xhr :get, :orgs_by_thirty_day_commit_volume, format: :js

      must_respond_with :ok
      assigns(:org_by_30_day_commits).must_equal [ota5, ota4, ota3, ota2, ota1]
    end

    it 'should return json of filtered record when filter is government' do
      OrgThirtyDayActivity.where(id: [ota5.id, ota4.id, ota3.id]).update_all(org_type: 3)
      xhr :get, :orgs_by_thirty_day_commit_volume, filter: 'government', format: 'js'

      must_respond_with :ok
      assigns(:org_by_30_day_commits).must_equal [ota5, ota4, ota3]
    end

    it 'should return json of filtered record when filter is all' do
      xhr :get, :orgs_by_thirty_day_commit_volume, filter: 'all', format: :js

      must_respond_with :ok
      assigns(:org_by_30_day_commits).must_equal [ota5, ota4, ota3, ota2, ota1]
    end
  end
end
