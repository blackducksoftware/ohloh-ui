class TopicsController < ApplicationController
  before_action :session_required, only: [:new, :create]
  before_action :admin_session_required, only: [:edit, :update, :destroy]
  before_action :find_forum_record, only: [:index, :new, :create, :edit]
  before_action :find_forum_and_topic_records, except: [:index, :new, :create]

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
    respond_to do |format|
      if verify_recaptcha(model: @topic) && @topic.save
        format.html { redirect_to forum_path(@forum), flash: { success: t('.success') } }
      else
        format.html { redirect_to forum_path(@forum), flash: { error: t('.error') } }
      end
    end
  end

  def show
    @posts = @topic.posts.paginate(page: params[:page], per_page: 25)
  end

  def update
    respond_to do |format|
      if @topic.update(topic_params)
        format.html { redirect_to forum_topic_path(@forum, @topic), flash: { success: t('.success') } }
      else
        format.html { redirect_to forum_topic_path(@forum, @topic), flash: { error: t('.error') } }
      end
    end
  end

  def destroy
    @topic.destroy
    respond_to do |format|
      format.html { redirect_to forums_path }
    end
  end

  private

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
