class PostsController < ApplicationController
  before_action :session_required, only: [:new, :create, :edit, :update]
  before_action :admin_session_required, only: [:destroy]
  before_action :find_forum_and_topic_records, except: :index
  before_action :find_post_record, only: [:edit, :update, :destroy]

  def index
    @posts = Post.all
  end

  def new
    @post = @topic.posts.build
  end

  def create
    @post = build_new_post
    respond_to do |format|
      if @post.save
        post_notification(@post)
        format.html { redirect_to topic_path(@topic), flash: { success: t('.success') } }
      else
        format.html { redirect_to topic_path(@topic), flash: { error: t('.error') } }
      end
    end
  end

  def edit
    return unless (current_user.id != @post.account_id) && (current_user_is_admin? == false)
    redirect_to forum_topic_path(@forum, @topic)
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to topic_path(@topic), flash: { success: t('.success') } }
      else
        format.html { redirect_to topic_path(@topic), flash: { error: t('.error') } }
      end
    end
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to forum_topic_path(@forum, @topic) }
    end
  end

  private

  def post_notification(post)
    @user_who_began_topic = post.topic.account
    @user_who_replied = post.account
    @topic = post.topic
    find_collection_of_users(post)
    unless @user_who_replied != @user_who_began_topic
      rejected = @all_users_preceding_the_last_user.reject { |user| user.id == @user_who_replied.id }
      @all_users_preceding_the_last_user = rejected
    end
    send_reply_emails_to_everyone(@all_users_preceding_the_last_user.uniq!)
    send_creation_email
  end

  def find_collection_of_users(post)
    @all_users_preceding_the_last_user = post.topic.posts.map(&:account)
    @all_users_preceding_the_last_user.pop
    @all_users_preceding_the_last_user
  end

  def send_reply_emails_to_everyone(_users)
    @all_users_preceding_the_last_user.each do |user|
      PostNotifier.post_replied_notification(user, @user_who_replied, @topic).deliver
    end
  end

  def send_creation_email
    PostNotifier.post_creation_notification(@user_who_replied, @topic).deliver
  end

  def find_post_record
    find_forum_and_topic_records
    @post = @topic.posts.find_by(id: params[:id])
  end

  def find_forum_and_topic_records
    @topic = Topic.find_by(id: params[:topic_id])
  end

  def post_params
    params.require(:post).permit(:body)
  end

  def build_new_post
    post = @topic.posts.build(post_params)
    post.account_id = current_user.id
    post
  end
end
