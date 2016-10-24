class ProjectBadgesController < ApplicationController
  before_action :set_project_or_fail
  before_action :session_required, :redirect_unverified_account, only: [:create, :destroy]
  before_action :set_project_editor_account_to_current_user
  before_action :check_project_authorization, except: [:index]
  before_action :project_context, only: [:index, :create]
  before_action :set_badges, only: [:index, :create]
  before_action :avoid_duplicate_creation, only: [:create]

  [TravisBadge, CiiBadge] if Rails.env == 'development'

  helper ProjectsHelper
  layout 'responsive_project_layout'

  def index
    @active_badges = @project.project_badges.active
    @project_badge = ProjectBadge.new
  end

  def create
    @project_badge = @project.project_badges.find_or_initialize_by(badge_params)
    if @project_badge.save
      save_and_redirect_valid_badge
    else
      @active_badges = @project.project_badges.active
      render :index, flash: { error: 'Badge cannot be created.' }
    end
  end

  def update
    @badge = @project.project_badges.find(params[:id])
    @badge = @badge.update_attributes(params[:project_badge].permit!)
    if @badge
      render json: { success: true, message: 'Badge updated successfully' }
    else
      render json: { success: false, message: 'Badge not updated' }
    end
  end

  def destroy
    @project_badge = ProjectBadge.find(params[:id])
    @project_badge.status = 0
    @project_badge.save
    redirect_to project_project_badges_path, flash: { success: 'Badge deleted successfully.' }
  end

  private

  def save_and_redirect_valid_badge
    @project_badge.status = 1
    @project_badge.save
    redirect_to project_project_badges_path, flash: { success: 'Badge created successfully.' }
  end

  def badge_params
    (params[:project_badge] || params[:cii_badge] || params[:travis_badge])
      .permit(:repository_id, :type, :identifier)
  end

  def set_badges
    @repositories = @project.repositories.map { |r| [r.url, r.id] }
    @badges = ProjectBadge.subclasses.map { |b| [b.badge_name, b.name] }
  end

  def avoid_duplicate_creation
    condition = @project.project_badges.active.where(badge_params).first
    redirect_to project_project_badges_path, flash: { error: 'Badge already exist for this repository' } if condition
  end
end
