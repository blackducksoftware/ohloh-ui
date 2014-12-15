require 'test_helper'

class PostsController < ApplicationController
  before_action :grab_forum_and_topic

  def index
    @posts = @topic.posts
  end

  def create
    @post = @topic.posts.build(post_params)
    respond_to do |format|
      if @post.save
        format.html { redirect_to forum_topic_path(@forum,@topic), flash: { success: t('.success') } }
      else
        format.html { redirect_to forum_topic_path(@forum,@topic), flash: { error: t('.error') } }
      end
    end
  end

  def edit
    @post = @topic.posts.find(params[:id])
  end

  def update
    @post = @topic.posts.find(params[:id])
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to forum_topic_path(@forum,@topic), flash: { success: t('.success') } }
      else
        format.html { redirect_to forum_topic_path(@forum,@topic), flash: { error: t('.error') } }
      end
    end
  end

  def destroy
    @post = @topic.posts.find(params[:id])
    @post.destroy
    respond_to do |format|
      format.html { redirect_to forum_topic_path(@forum,@topic) }
    end
  end

  private

  def post_params
    params.require(:post).permit(:topic_id, :account_id, :body)
  end

  def grab_forum_and_topic
    @forum = Forum.find(params[:forum_id])
    @topic = @forum.topics.find(params[:topic_id])
  end

end