# frozen_string_literal: true

class ExploreController < ApplicationController
  helper :Projects

  before_action :set_language, only: %i[index projects]
  before_action :projects_details, unless: :language_or_cache_exist, only: %i[index projects]
  skip_before_action :verify_authenticity_token, only: [:orgs_by_thirty_day_commit_volume]

  def index
    render 'explore/projects'
  end

  def demographic_chart
    render json: Project::DemographicChart.data
  end

  def orgs
    @newest_orgs = Organization.active.order(created_at: :desc).limit(3)
    @most_active_orgs = OrgThirtyDayActivity.most_active_orgs
    @stats_by_sector = OrgStatsBySector.recent
    @org_by_30_day_commits = OrgThirtyDayActivity.filter_all_orgs
  end

  def orgs_by_thirty_day_commit_volume
    @org_by_30_day_commits = OrgThirtyDayActivity.filter(params[:filter])
  end

  def projects; end

  private

  def language_or_cache_exist
    @language.blank? && Rails.cache.exist?('projects_explore_page')
  end

  def projects_details
    @tags = CloudTag.list
    @languages = Language.map
    @projects = @language ? Project.hot(@language.id).limit(10) : Project.hot.limit(10)
    @project_logos_map = Logo.where(id: @projects.map(&:logo_id)).index_by(&:id)
    @total_count = Project.active.count
    @with_pai_count = Project.with_pai_available
  end

  def set_language
    @language = Language.find_by(name: params[:lang].downcase) if params[:lang].present?
  end
end
