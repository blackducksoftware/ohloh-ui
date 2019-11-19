# frozen_string_literal: true

module OrgFilters
  extend ActiveSupport::Concern

  included do
    before_action :set_organization, except: %i[index new create
                                                resolve_vanity_url print_org_infographic update]
    before_action :set_organization_based_on_id, only: [:update]
    before_action :organization_context, except: [:print_infographic]
    before_action :session_required, only: %i[new create]
    before_action :admin_session_required, only: %i[new create]
    before_action :handle_default_view, only: :show
    before_action :set_editor, only: %i[list_managers new_manager claim_projects_list claim_project]
    before_action :show_permissions_alert, only: %i[manage_projects new_manager edit
                                                    claim_projects_list list_managers settings]
    before_action :redirect_ro_explores_pages, only: :index
    before_action :set_project, only: %i[claim_project remove_project]
    before_action :can_claim_project, only: :claim_project
    after_action :schedule_analysis, only: %i[claim_project remove_project]
    before_action :avoid_global_search, only: %i[manage_projects claim_projects_list]
  end

  def schedule_analysis
    @organization.schedule_analysis
  end

  private

  def set_organization
    @organization ||= Organization.from_param(params[:id]).take
    raise ParamRecordNotFound if @organization.nil?

    @organization.editor_account = current_user
  end

  def set_organization_based_on_id
    @organization = Organization.find_by(id: params[:organization][:id])
    set_organization
  end

  def set_editor
    @organization.editor_account = current_user
  end

  def handle_default_view
    show_views = %w[affiliated_committers portfolio_projects outside_committers outside_projects]
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
    pictogram_html = render_to_string(partial: 'organizations/show/pictogram')
    render json: { subview_html: subview_html, pictogram_html: pictogram_html }
  end

  def organization_params
    params.require(:organization).permit(%i[name description vanity_url org_type homepage_url])
  end

  def redirect_ro_explores_pages
    redirect_to orgs_explores_path if request.format == 'html' && request.query_string.blank?
  end

  def can_claim_project
    render text: t('.unauthorized') unless request.xhr? && @organization.edit_authorized?
  end

  def set_project
    @project = Project.from_param(params[:project_id]).take
    raise ParamRecordNotFound unless @project
  end
end
