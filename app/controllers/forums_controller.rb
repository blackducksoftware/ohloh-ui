# frozen_string_literal: true

class ForumsController < ApplicationController
  before_action :find_most_recent_topics_from_forum, only: :index
  before_action :find_forum_record, except: %i[index new create]
  before_action :session_required, except: %i[index show]
  before_action :admin_session_required, except: %i[index show]

  def index
    # General Discussion is not on the production website.
    # The created_at and updated_at fields for all forums have been removed
    # for some reason. Hence the newest forum will have the highest primary id
    # and will be sorted by primary id.
    @forums = Forum.where("name != 'General Discussion'").order(id: :desc).limit(10)
  end

  def new
    @forum = Forum.new
  end

  def create
    @forum = Forum.new(forum_params)
    if @forum.save
      redirect_to forums_path
    else
      flash[:alert] = t('.error')
      render :new
    end
  end

  def show
    @topics = @forum.topics.includes(:account, posts: :account).paginate(page: page_param, per_page: 15)
  end

  def update
    if @forum.update(forum_params)
      redirect_to forums_path
    else
      flash[:alert] = t('.error')
      render :edit
    end
  end

  def destroy
    @forum.destroy
    redirect_to forums_path
  end

  private

  def find_forum_record
    @forum = Forum.where(id: params[:id]).take
    raise ParamRecordNotFound unless @forum
  end

  def forum_params
    params.require(:forum).permit(:name, :position, :description)
  end

  def find_most_recent_topics_from_forum
    @recent_topics = Topic.recent
  end
end
