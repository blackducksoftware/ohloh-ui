class OrganizationsController < ApplicationController
  helper ProjectsHelper
  helper RatingsHelper
  helper OrganizationsHelper

  include OrgFilters

  def index
    @organizations = Organization.search_and_sort(params[:query], params[:sort], params[:page])
  end

  def new
    @organization = Organization.new(editor_account: current_user)
  end

  def create
    @organization = Organization.new({ editor_account: current_user }.merge(organization_params))
    if @organization.save
      redirect_to organization_path(@organization), notice: t('.notice')
    else
      flash.now[:error] = t('.error')
      render :new
    end
  end

  def edit
    @current_object = @organization
  end

  def update
    return render_unauthorized unless @organization.edit_authorized?
    if @organization.update_attributes(organization_params)
      redirect_to organization_path(@organization), notice: t('.notice')
    else
      @current_object = @organization.clone
      @organization.reload
      flash.now[:error] = t('.failure')
      render :edit, status: :unprocessable_entity
    end
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
    params[:sort] ||= 'project_name'
    return if params[:query].blank?
    @projects = Project.active.search_and_sort(params[:query], params[:sort], params[:page])
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
    @projects = @organization.projects.search_and_sort(params[:query], params[:sort], params[:page])
  end

  def remove_project
    if @project.edits.find_by(key: 'organization_id').try(:undo!, current_user)
      flash[:success] = t('.success', name: @project.name.to_s)
    else
      flash[:error] = t('.error')
    end

    redirect_path = manage_projects_organization_path(@organization) if params[:source] == 'manage_projects'
    redirect_to (redirect_path || claim_projects_list_organization_path(@organization))
  end

  def outside_projects
    @outside_projects = @organization.outside_projects(params[:page], @per_page || 20)
  end

  def projects
    @affiliated_projects = @organization.affiliated_projects(params[:page], @per_page || 20)
  end

  def portfolio_projects
    projects
  end

  def print_infographic
    render layout: false
  end

  def affiliated_committers
    @affiliated_committers = @organization.affiliated_committers(params[:page], @per_page || 20)
    @stats_map = Account::CommitCore.new(@affiliated_committers.map(&:id)).most_and_recent_data
  end

  def outside_committers
    @outside_committers = @organization.outside_committers(params[:page], @per_page || 20)
  end
end
