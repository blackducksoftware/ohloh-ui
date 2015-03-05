class ExploreController < ApplicationController
  def orgs
    @newest_orgs = Organization.active.order(created_at: :desc).limit(3)
    @most_active_orgs = OrgThirtyDayActivity.most_active_orgs
    @stats_by_sector = OrgStatsBySector.recent
    @org_by_30_day_commits = OrgThirtyDayActivity.send("filter_#{params[:filter]}_orgs")
  end

  def orgs_by_thirty_day_commit_volume
    @org_by_30_day_commits = OrgThirtyDayActivity.send("filter_#{params[:filter]}_orgs")
  end
end
