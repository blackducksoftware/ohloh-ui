class OrganizationsController < ApplicationController
  helper ProjectsHelper
  helper RatingsHelper
  helper OrganizationsHelper

  before_action :find_organization
  before_action :organization_context, except: [:print_infographic]
  before_action :handle_default_view, only: :show
  #before_action :load_infographics_table, only: :show

  def show
    @graphics = OrgInfoGraphics.new(@organization)
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
    # @affiliated_committers = @organization.affiliated_committers((params[:page] || 1), @per_page || 20)
    # @stats_map = Account::CommitCore.new(@affiliated_committers.map(&:id)).most_and_recent_data

    File.open('aff_com') do |f|
      @affiliated_committers = Marshal.load(f)
    end

    File.open('stats_map') do |f|
      @stats_map = Marshal.load(f)
    end

  end

  def outside_committers
    @outside_committers = @organization.outside_committers(params[:page], @per_page || 20)
  end

  private

  def find_organization
    @organization = Organization.from_param(params[:id]).take
    fail ParamRecordNotFound if @organization.nil?
  end

  def handle_default_view
    show_views = %w(affiliated_committers portfolio_projects outside_committers outside_projects)
    @view = show_views.include?(params[:view]) ? params[:view].to_sym : default_view
    @per_page = 10 if params[:action] == 'show'
    send(@view)
  end

  def default_view
    @organization.affiliators_count >= @organization.projects_count ? :affiliated_committers : :portfolio_projects
  end

  def load_infographics_table
    if request.xhr?
      @graphics ||= OrgInfoGraphics.new(@organization)
      subview_html = render_to_string(:partial => "organizations/show/#{@view}")
      pictogram_html = render_to_string(:partial => "organizations/show/pictogram")
      render :json => { subview_html: subview_html, pictogram_html: pictogram_html }
    end
  end
end
