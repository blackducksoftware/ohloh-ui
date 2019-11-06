# frozen_string_literal: true

# rubocop:disable SkipsModelValidations

class OrganizationsController < ApplicationController
  helper ProjectsHelper
  helper RatingsHelper
  helper OrganizationsHelper

  include OrgFilters

  def index
    @organizations = Organization.search_and_sort(params[:query], params[:sort], page_param)
  end

  def new
    @organization = Organization.new(editor_account: current_user)
  end

  def create
    @organization = Organization.new({ editor_account: current_user }.merge(organization_params))
    @organization.save!
    redirect_to organization_path(@organization), notice: t('.notice')
  rescue StandardError
    flash.now[:error] = t('.error')
    render :new
  end

  def edit
    @current_object = @organization
  end

  def update
    return render_unauthorized unless @organization.edit_authorized?

    @organization.update!(organization_params)
    redirect_to organization_path(@organization), notice: t('.notice')
  rescue StandardError
    @current_object = @organization
    flash.now[:error] = t('.failure')
    render :edit, status: :unprocessable_entity
  end

  def show
    @graphics = OrgInfoGraphics.new(@organization, context: { view: @view })
    load_infographics_table
  end

  def list_managers
    @managers = @organization.managers
  end

  def new_manager
    @manage = @organization.manages.new(account_id: params[:account_id], approver: Account.hamster)
    return if request.get?

    redirect_to list_managers_organization_path(@organization), flash: { success: t('.success') } if @manage.save
  end

  def claim_projects_list
    @projects = []
    params[:sort] ||= 'relevance'
    return if params[:query].blank?

    @projects = Project.active.search_and_sort(params[:query], params[:sort], page_param)
  end

  def claim_project
    @project.editor_account = current_user
    if @project.update_attribute(:organization_id, @organization.id)
      render partial: 'active_remove_project_button', locals: { p: @project }
    else
      render text: t('.failed')
    end
  end

  def manage_projects
    params[:sort] ||= 'new'
    @projects = @organization.projects.search_and_sort(params[:query], params[:sort], page_param)
  end

  def remove_project
    if @project.edits.find_by(key: 'organization_id').try(:undo!, current_user)
      flash[:success] = t('.success', name: @project.name.to_s)
    else
      flash[:error] = t('.error')
    end

    redirect_to remove_project_redirect
  end

  def outside_projects
    @outside_projects = @organization.outside_projects(page_param, @per_page || 20)
  end

  def projects
    @affiliated_projects = @organization.affiliated_projects(page_param, @per_page || 20)

    redirect_to organization_path(@organization), notice: t('.notice') if @affiliated_projects.blank?
  end

  def portfolio_projects
    projects
  end

  def print_infographic
    render layout: false
  end

  def affiliated_committers
    @affiliated_committers = @organization.affiliated_committers(page_param, @per_page || 20)
    @stats_map = Account::CommitCore.new(@affiliated_committers.map(&:id)).most_and_recent_data
  end

  def outside_committers
    @outside_committers = @organization.outside_committers(page_param, @per_page || 20)
  end

  private

  def remove_project_redirect
    if params[:source] == 'manage_projects'
      manage_projects_organization_path(@organization)
    else
      claim_projects_list_organization_path(@organization)
    end
  end
end

# rubocop:enable SkipsModelValidations
