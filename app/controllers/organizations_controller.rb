class OrganizationsController < ApplicationController
  helper ProjectsHelper
  helper RatingsHelper
  helper OrganizationsHelper

  before_action :set_organization, except: [:index, :new, :create, :resolve_url_name, :print_org_infographic, :update]
  before_action :set_organization_based_on_id, only: [:update]
  before_action :organization_context, except: [:print_infographic]
  before_action :admin_session_required, only: [:new, :create]
  before_action :handle_default_view, only: :show
  before_action :set_editor, only: [:list_managers, :new_manager, :claim_projects_list, :claim_project]
  before_action :show_permissions_alert, only: [:manage_projects, :new_manager, :edit,
                                                :claim_projects_list, :list_managers, :settings]

  def index
    redirect_to orgs_explores_path if request.format == 'html' && request.query_string.blank?
    @organizations = Organization.search_and_sort(params[:query], params[:sort], params[:page])
  end

  def new
    @organization = Organization.new({ editor_account: current_user })
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
    render text: t('.unauthorized') && return unless request.xhr? && @organization.edit_authorized?
    @project = Project.from_param(params[:project_id]).take
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
    project = Project.from_param(params[:project_id]).take
    if project.edits.find_by(key: 'organization_id').try(:undo!, current_user)
      flash[:success] = t('.success', name: project.name.to_s)
    else
      flash[:error] = t('.error')
    end
    redirect_to manage_projects_organization_path(@organization)
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

  private

  def set_organization
    @organization ||= Organization.from_param(params[:id]).take
    fail ParamRecordNotFound if @organization.nil?
    @organization.editor_account = current_user
  end

  def set_organization_based_on_id
    @organization = Organization.find_by_id(params[:organization][:id])
    set_organization
  end

  def set_editor
    @organization.editor_account = current_user
  end

  def handle_default_view
    show_views = %w(affiliated_committers portfolio_projects outside_committers outside_projects)
    view = show_views.find { |defined_view| defined_view == params[:view] }
    @view = view.nil? ? default_view : view.to_sym
    @per_page = 10 if params[:action] == 'show'
    send(@view)
  end

  def default_view
    @organization.affiliators_count >= @organization.projects_count ? :affiliated_committers : :portfolio_projects
  end

  def load_infographics_table
    return unless request.xhr?
    @graphics ||= OrgInfoGraphics.new(@organization)
    subview_html = render_to_string(partial: "organizations/show/#{@view}")
    pictogram_html = render_to_string(partial:  'organizations/show/pictogram')
    render json: { subview_html: subview_html, pictogram_html: pictogram_html }
  end

  def organization_params
    params.require(:organization).permit([:name, :description, :url_name, :org_type, :homepage_url])
  end
end
