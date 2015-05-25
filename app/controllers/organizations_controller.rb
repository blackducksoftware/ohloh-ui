class OrganizationsController < ApplicationController
  helper ProjectsHelper
  helper RatingsHelper
  helper OrganizationsHelper

  before_action :set_organization, except: [:index, :create]
  before_action :organization_context, except: [:print_infographic, :create, :update]
  before_action :handle_default_view, only: :show

  def index
    redirect_to orgs_explores_path if request.format == 'html' && request.query_string.blank?
    @organizations = Organization.search_and_sort(params[:query], params[:sort], params[:page])
  end

  def create
    if Organization.create(params[:organization])
      redirect_to organization_path(@organization), notice: 'Organization has been created successfully'
    else
      render :new
    end
  end

  def update
    if @organization.update_attributes(params[:organization])
      redirect_to organization_path(@organization), notice: 'Organization changes were saved successfully'
    else
      render :edit, :status => 422
    end
  end

  def show
    @graphics = OrgInfoGraphics.new(@organization, context: { view: @view })
    load_infographics_table
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
