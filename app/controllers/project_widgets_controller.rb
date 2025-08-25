# frozen_string_literal: true

class ProjectWidgetsController < WidgetsController
  helper :Projects, :Analyses
  before_action :set_project
  before_action :render_image_for_gif_format, only: %i[partner_badge thin_badge]
  before_action :render_not_supported_for_gif_format, except: %i[partner_badge thin_badge index]
  before_action :render_iframe_for_js_format
  before_action :project_context, only: :index

  def index
    @widgets = Widget::ProjectWidget.create_widgets(params[:project_id])
  end

  def partner_badge; end

  def thin_badge; end

  private

  def set_project
    @project = Project.by_vanity_url_or_id(params[:project_id]).take!

    project_context
    render 'projects/deleted' if @project.deleted?
  end
end
