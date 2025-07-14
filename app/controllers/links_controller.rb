# frozen_string_literal: true

class LinksController < SettingsController
  helper ProjectsHelper

  before_action :set_project_or_fail, :set_project_editor_account_to_current_user
  before_action :project_context
  before_action :set_link, only: %i[edit update destroy]
  before_action :session_required, :redirect_unverified_account, only: %i[create new edit update]
  before_action :set_categories, only: %i[create new edit update]

  def index
    @links = @project.links
  end

  def new
    @link = Link.new
    load_category_and_title
  end

  def edit
    load_category_and_title
  end

  def create
    @link = @project.links.new(link_params)
    @link.editor_account = current_user

    if @link.revive_or_create
      redirect_to project_links_path(@project), flash: { success: t('.success') }
    else
      load_category_and_title
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @link.update(link_params)
      redirect_to project_links_path(@project), flash: { success: t('.success') }
    else
      load_category_and_title
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @link.destroy
      redirect_to project_links_path(@project), flash: { success: t('.success') }
    else
      flash[:error] = t('.error')
      redirect_to_saved_path(current_user)
    end
  end

  private

  def load_category_and_title
    @category_name = Link.find_category_by_id(params[:category_id]) || @link.category
    return unless @link && @category_name

    type = nil
    type = :Homepage if @category_name.to_s == 'Homepage'
    type = :Downloads if @category_name.to_s == 'Download'
    @link.title ||= type
  end

  def set_link
    @link = Link.find(params[:id])
    @link.editor_account = current_user
  end

  def set_categories
    @categories = applicable_categories
  end

  def applicable_categories
    return Link::CATEGORIES if occupied_category_ids.empty? ||
                               %w[edit update].include?(action_name)

    Link::CATEGORIES.reject do |_k, category_id|
      occupied_category_ids.include?(category_id)
    end
  end

  def occupied_category_ids
    @project.links
            .where(link_category_id: Link::CATEGORIES.values_at(:Homepage, :Download))
            .pluck(:link_category_id)
  end

  def link_params
    params.require(:link).permit(%i[title url project_id link_category_id])
  end
end
