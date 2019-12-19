# frozen_string_literal: true

class RssArticlesController < ApplicationController
  helper :projects
  before_action :set_project_or_fail, :set_project_editor_account_to_current_user
  before_action :project_context

  def index
    @rss_articles = @project.rss_articles.paginate(page: page_param, per_page: 10)
  end
end
