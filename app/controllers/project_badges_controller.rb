class ProjectBadgesController < ApplicationController
  before_action :set_project_or_fail
  before_action :session_required, :redirect_unverified_account, only: [:create, :destroy]
  before_action :set_project_editor_account_to_current_user
  before_action :check_project_authorization, except: [:index]
  before_action :project_context, only: [:index, :create]
  before_action :set_badges, only: [:index, :create]
  before_action :set_active_badges, only: [:index, :create]
  before_action :avoid_duplicate_creation, only: [:create]
  before_action :find_badge, only: [:update, :destroy]

  helper ProjectsHelper
  layout 'responsive_project_layout'

  def index
    @project_badge = ProjectBadge.new
  end

  def create
    @project_badge = @project.project_badges.inactive.find_or_initialize_by(badge_params.except('identifier'))
    @project_badge.identifier = badge_params['identifier']
    if @project_badge.save
      save_and_redirect_valid_badge
    else
      render :index, flash: { error: I18n.t('project_badges.create_failed') }
    end
  end

  def update
    if @badge.update(identifier: params[:project_badge][:identifier])
      render json: { success: true,
                     message: I18n.t('project_badges.update_success'),
                     value: @badge.identifier }
    else
      render json: { success: false,
                     errors: @badge.errors[:identifier].join(', ') }
    end
  end

  def destroy
    @badge.inactive!
    redirect_to project_project_badges_path, flash: { success: I18n.t('project_badges.delete_success') }
  end

  private

  def find_badge
    @badge = ProjectBadge.find(params[:id])
  end

  def save_and_redirect_valid_badge
    @project_badge.active!
    redirect_to project_project_badges_path, flash: { success: I18n.t('project_badges.create_success') }
  end

  def badge_params
    (params[:project_badge] || params[:cii_badge] || params[:travis_badge])
      .permit(:enlistment_id, :type, :identifier)
  end

  def set_badges
    @enlistments = @project.enlistments.map { |e| [e.code_location.url, e.id] }
    @badges = ProjectBadge.subclasses.map { |b| [b.badge_name, b.name] }
  end

  def avoid_duplicate_creation
    if @active_badges.where(badge_params).first
      redirect_to project_project_badges_path, flash: { error: I18n.t('project_badges.already_exist') }
    end
  end

  def set_active_badges
    @active_badges = @project.project_badges.active
  end
end
