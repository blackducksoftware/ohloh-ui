class ProjectWidgetsController < WidgetsController
  before_action :set_project
  before_action :render_gif_image, only: [:partner_badge, :thin_badge]
  before_action :render_not_supported_thin_badge, except: [:partner_badge, :thin_badge, :index]
  before_action :render_for_js_format

  def index
    @widgets = ProjectWidget.create_widgets(params[:project_id])
  end

  private

  def set_project
    @project = Project.from_param(params[:project_id]).first!
  end
end
