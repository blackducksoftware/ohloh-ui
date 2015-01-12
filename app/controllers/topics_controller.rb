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
    @topic = @forum.topics.build(topic_params)
    respond_to do |format|
      if @topic.save
        format.html { redirect_to forum_path(@forum), flash: { success: t('.success') } }
      else
        format.html { redirect_to forum_path(@forum), flash: { error: t('.error') } }
      end
    end
  end

  def update
    respond_to do |format|
      if @topic.update(topic_params)
        format.html { redirect_to forum_topic_path(@forum,@topic), flash: { success: t('.success') } }
      else
        format.html { redirect_to forum_topic_path(@forum,@topic), flash: { error: t('.error') } }
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
    @forum = Forum.find_by(id: params[:forum_id])
    @topic = @forum.topics.find_by(id: params[:id])
  end

  def topic_params
    params.require(:topic).permit(:forum_id, :account_id, :title, :sticky, :hits, :closed, :posts_count, posts_attributes:[:body, :account_id])
  end
end