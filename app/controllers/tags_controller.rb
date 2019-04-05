class TagsController < ApplicationController
  helper ProjectsHelper
  helper RatingsHelper

  before_action :set_session_projects, only: :index
  before_action :find_tag_names, only: :index
  before_action :find_models, only: [:index]
  # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :show_permissions_alert, only: :select
  # rubocop:enable Rails/LexicallyScopedActionFilter
  def index; end

  private

  def find_tag_names
    params[:names] ||= get_tag_names
  end

  def get_tag_names
    params[:name].split('/') if params[:name]
  end

  def find_models
    params[:names] ? find_projects_by_names : find_tags_by_popularity
  end

  def find_projects_by_names
    @projects = Project.tagged_with(params[:names])
                       .includes([[best_analysis: :main_language], :logo, :organization, :licenses])
                       .order(user_count: :desc)
                       .page(page_param).per_page(10)
    @projects.each { |proj| proj.editor_account = current_user }
    find_related_tags
  end

  def find_related_tags
    related_tags = Tag.related_tags(params[:names])
                      .order(count: :desc)
                      .select("name|| ' (' || count(*) || ')' tag, name")
                      .map { |t| [t.tag, t.name] }
    @related_tags = find_tags + related_tags
  end

  def find_tags
    Tag.where(name: params[:names]).select("name||' (' || taggings_count || ')' tag, name")
       .map { |t| [t.tag, t.name] }
  end

  def find_tags_by_popularity
    @tags = Tag.popular.paginate(page: page_param, per_page: 48)
    render template: 'tags/cloud'
  end
end
