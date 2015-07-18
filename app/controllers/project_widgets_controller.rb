class ProjectWidgetsController < WidgetsController
  helper :Projects, :Analyses
  before_action :set_project
  before_action :render_image_for_gif_format, only: [:project_partner_badge, :thin_badge]
  before_action :render_not_supported_for_gif_format, except: [:project_partner_badge, :thin_badge, :index]
  before_action :render_iframe_for_js_format
  before_action :project_context, only: :index

  def index
    @widgets = ProjectWidget.create_widgets(params[:project_id])
  end

  private

  def set_project
    @project = Project.from_param(params[:project_id]).first!
  end
end
