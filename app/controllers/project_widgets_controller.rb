class ProjectWidgetsController < WidgetsController
  BADGE_URLS = [:partner_badge, :thin_badge, :vulnerability_exposure_badge, :security_exposure_badge,
                :language_badge, :last_update_badge, :rating_badge, :recent_contributors_badge,
                :monthly_statistics_badge, :yearly_statistics_badge].freeze
  helper :Projects, :Analyses, :ProjectVulnerabilityReports
  before_action :set_project
  before_action :render_image_for_gif_format, only: BADGE_URLS
  before_action :render_not_supported_for_gif_format, except: BADGE_URLS + [:index]
  before_action :render_iframe_for_js_format
  before_action :project_context, only: :index

  def index
    @widgets = ProjectWidget.create_widgets(params[:project_id])
  end

  private

  def set_project
    @project = Project.by_vanity_url_or_id(params[:project_id]).take!

    project_context
    render 'projects/deleted' if @project.deleted?
  end
end
