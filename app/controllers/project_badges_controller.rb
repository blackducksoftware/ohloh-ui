class ProjectBadgesController < ApplicationController
  before_action :set_project_or_fail
  before_action :session_required, :redirect_unverified_account, only: [:create, :destroy]
  before_action :set_project_editor_account_to_current_user
  before_action :check_project_authorization, except: [:index]
  before_action :project_context, only: [:index, :create]
  before_action :set_badges, only: [:index, :create]
  [CiiBadge, TravisBadge] if Rails.env == 'development'

  helper ProjectsHelper
  layout 'responsive_project_layout'

  def index
    @project_badge = ProjectBadge.new
  end

  def create
    binding.pry
    @project_badge = @project.project_badges.find_or_initialize_by(badge_params)
    if @project_badge && @project_badge.valid?
      save_and_redirect_valid_badge
    else
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

  def set_badges
    @badges = ProjectBadge.subclasses.map{ |b| [b.method(:badge_name).call, b.name] }
  end
end
