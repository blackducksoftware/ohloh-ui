class TagsController < ApplicationController
  helper ProjectsHelper
  helper RatingsHelper

  before_action :find_models, only: [:index]
  before_action :show_permissions_alert, only: :select

  private

  def find_models
    params[:names] ? find_projects_by_names : find_tags_by_popularity
  end

  def find_projects_by_names
    @names = params[:names].split(',').collect { |name| CGI.unescape(name.gsub('+', '%2B')) }.uniq
    @projects = projects_with_all_tags(Tag.where(name: @names).pluck(:id))
    @projects.each { |proj| proj.editor_account = current_user }
  end

  def find_tags_by_popularity
    @tags = Tag.popular.paginate(page: params[:page], per_page: 48)
    render template: 'tags/cloud'
  end

  def projects_with_all_tags(tag_ids)
    ins = tag_ids.collect do |tag_id|
      "projects.id IN (SELECT taggable_id FROM taggings WHERE tag_id=#{tag_id} AND taggable_type='Project')"
    end
    Project.not_deleted.where(ins.join(' AND ')).order(user_count: :desc).paginate(page: params[:page], per_page: 10)
  end
end
