class TopicsController < ApplicationController 
  before_action :grab_forum_and_topic, except: [:index,:new,:create]
  def index
    @forum = Forum.find(params[:forum_id])
    @topics = @forum.topics
  end

  def new
    @forum = Forum.find(params[:forum_id])
    @topic = @forum.topics.build
    @post = @topic.posts.build
  end

  def create
    @forum = Forum.find(params[:forum_id])
    @topic = @forum.topics.build(topic_params)
    respond_to do |format|
      if @topic.save
        format.html { redirect_to forum_path(@forum), flash: { success: t('.success') } }
      else
        format.html { redirect_to forum_path(@forum), flash: { error: t('.error') } }
      end
    end
  end

  def show
  end

  def edit
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

  def grab_forum_and_topic
    @forum = Forum.find(params[:forum_id])
    @topic = @forum.topics.find(params[:id])
  end

  def topic_params
    params.require(:topic).permit(:forum_id, :account_id, :title, :sticky, :closed, :hits, :posts_count, posts_attributes:[:body, :account_id])
  end

end