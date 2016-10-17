class ProjectBadgesController < ApplicationController
  before_action :set_project_or_fail
  before_action :show_permissions_alert, only: [:create, :destroy]
  [CiiBadge, TravisBadge] if Rails.env == 'development'

  helper ProjectsHelper
  layout 'responsive_project_layout'

  def index
    @badges = ProjectBadge.subclasses.map(&:name)
    @project_badge = ProjectBadge.new
  end

  def create
    @project_badge = @project.project_badges.find_or_initialize_by(badge_params)
    if @project_badge && @project_badge.valid?
      save_and_redirect_valid_badge
    else
      @badges = ProjectBadge.subclasses.map(&:name)
      flash[:warning] = 'Badge cannot be created.'
      render :index
    end
  end

  def destroy
    @project_badge = ProjectBadge.find(params[:id])
    @project_badge.deleted = true
    @project_badge.save
    flash[:success] = 'Badge deleted successfully.'
    redirect_to project_project_badges_path
  end

  private

  def save_and_redirect_valid_badge
    @project_badge.deleted = false
    @project_badge.save
    flash[:success] = 'Badge created successfully.'
    redirect_to project_project_badges_path
  end

  def badge_params
    if params[:project_badge]
      params.require(:project_badge).permit(:repository_id, :type, :url)
    elsif params[:cii_badge]
      params.require(:cii_badge).permit(:repository_id, :type, :url)
    else
      params.require(:travis_badge).permit(:repository_id, :type, :url)
    end
  end
end
