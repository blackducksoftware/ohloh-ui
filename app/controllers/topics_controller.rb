class TopicsController < ApplicationController
  include TopicsHelper
  before_action :session_required, only: [:new, :create]
  before_action :admin_session_required, only: [:edit, :update, :destroy, :move_topic]
  before_action :find_forum_record, only: [:index, :new, :create]
  before_action :find_forum_and_topic_records, except: [:index, :new, :create, :move_topic]
  after_action :track_views, only: [:show]

  def index
    @topics = @forum.topics
    redirect_to forum_path(@forum)
  end

  def new
    @topic = @forum.topics.build
    @post = @topic.posts.build
    redirect_to new_session_path unless logged_in?
  end

  def create
    @topic = build_new_topic
    if verify_recaptcha(model: @topic) && @topic.save
      redirect_to forum_path(@forum)
    else
      render :new
    end
  end

  def show
    @posts = @topic.posts.paginate(page: params[:page], per_page: 25)
  end

  def update
    if @topic.update(topic_params)
      redirect_to topic_path(@topic)
    else
      render :edit
    end
  end

  def destroy
    if @topic.destroy
      flash[:notice] = t('.success', topic_title: @topic.title)
      redirect_to forums_path
    else
      redirect_to forums_path
    end
  end

  private

  def track_views
    topic = Topic.find_by(id: params[:id])
    topic.increment!(:hits) unless logged_in? && (@topic.account == current_user)
  end

  def find_forum_record
    @forum = Forum.find_by(id: params[:forum_id])
  end

  def find_forum_and_topic_records
    @topic = Topic.find_by(id: params[:id])
    @forum = @topic.forum
  end

  def topic_params
    params.require(:topic).permit(:forum_id, :title, :sticky,
                                  :hits, :closed, posts_attributes: [:body])
  end

  def build_new_topic
    topic = @forum.topics.build(topic_params)
    topic.account_id = current_user.id
    topic.posts.last.account_id = current_user.id
    topic
  end
end
