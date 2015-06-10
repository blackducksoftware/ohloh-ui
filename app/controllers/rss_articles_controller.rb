class RssArticlesController < ApplicationController
  helper :projects
  before_action :find_project
  before_action :project_context

  def index
    @rss_articles = @project.rss_articles.paginate(page: params[:page], per_page: 10)
  end

  private

  def find_project
    @project = Project.from_param(params[:project_id]).take
    fail ParamRecordNotFound unless @project
    @project.editor_account = current_user
  end
end
