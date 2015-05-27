class OrganizationsController < ApplicationController
  helper ProjectsHelper
  helper RatingsHelper
  helper OrganizationsHelper

  before_action :set_organization, except: [:index, :new, :create, :resolve_url_name, :print_org_infographic]
  before_action :organization_context, except: [:print_infographic, :create, :update]
  # before_filter :admin_required, :only => [:new, :create]
  before_action :handle_default_view, only: :show
  # before_filter :show_permissions_alert, only: [:new, :edit, :list_managers, :manage_projects, :new_manager,
                                                # :claim_projects_list, :settings]

  def index
    redirect_to orgs_explores_path if request.format == 'html' && request.query_string.blank?
    @organizations = Organization.search_and_sort(params[:query], params[:sort], params[:page])
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.create(params[:organization])
    if @organization
      redirect_to organization_path(@organization), notice: t('.notice')
    else
      render :new
    end
  end

  def update
    if @organization.update_attributes(params[:organization])
      redirect_to organization_path(@organization), notice: t('.notice')
    else
      render :edit, status: 422
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
    redirect_to managers_url_for(@organization), flash: { success: t('.success') } if @manage.save
  end

  def claim_projects_list
    @projects = []
    params[:sort] ||= 'relevance'
    return if params[:query].blank?
    @projects = Project.tsearch(params[:query], "by_#{params[:sort]}")
      .where.not(deleted: true).includes(:best_analysis)
      .paginate(page: params[:page], per_page: 20)
  end

  def claim_project
    render text: t('.unauthorized') unless request.xhr? && @organization.edit_authorized?
    @project = Project.from_param(params[:project_id]).take
    if @project.update_attribute(:organization_id, @organization.id)
      render partial: 'active_remove_project_button', locals: { p: @project, source: :claim }
    else
      render text: t('.failed')
    end
  end

  def manage_projects
    params[:sort] ||= 'new'
    @projects = Project.tsearch(params[:query], "by_#{params[:sort]}")
                .includes(:best_analysis).paginate(page: params[:page], per_page: 20)
  end

  def remove_project
    project = Project.from_param(params[:project_id]).take
    edits = project.edits.find_by(key: 'organization_id')
    edits.try(:undo) ? flash[:success] = t('.success') : flash[:error] = t('.error')

    if params[:source]
      redirect_to manage_projects_organization_path(@organization)
    else
      redirect_to claim_projects_list_organization_path(@organization)
    end
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
    @organization = Organization.from_param(params[:id]).take
    fail ParamRecordNotFound if @organization.nil?
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
end
