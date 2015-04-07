class TagsController < ApplicationController
  before_action :find_tags, only: [:index]

  private

  def find_tags
    params[:names] ? find_tags_by_params : find_tags_by_popularity
  end

  def find_tags_by_params
    @tags = Tag.where(name: params[:names].split(',')).paginate(page: params[:page], per_page: 10)
  end

  def find_tags_by_popularity
    @tags = Tag.popular.paginate(page: params[:page], per_page: 48)
    render template: 'tags/cloud'
  end
end
