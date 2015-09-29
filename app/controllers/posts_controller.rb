# rubocop:disable Metrics/ClassLength
class PostsController < ApplicationController
  include RedirectIfDisabled
  helper MarkdownHelper
  helper PageContextHelper

  before_action :session_required, :redirect_unverified_account, only: [:create, :edit, :update]
  before_action :admin_session_required, only: [:destroy]
  before_action :find_relevant_records, except: [:index]
  before_action :find_post_record, only: [:edit, :update, :destroy]
  before_action :find_posts, only: [:index]

  def index
    respond_to do |format|
      format.html
      format.atom
      format.rss { render 'index.atom.builder' }
    end
  end

  def create
    @post = build_new_post
    if verify_captcha_for_non_admin && @post.save
      post_notification(@post)
      redirect_to topic_path(@topic)
    else
      @posts = @topic.posts.paginate(page: page_param, per_page: TopicDecorator::PER_PAGE)
      render 'topics/show'
    end
  end

  def edit
    return unless (current_user.id != @post.account_id) && (current_user_is_admin? == false)
    redirect_to topic_path(@topic)
  end

  def update
    if verify_captcha_for_non_admin && @post.update(post_params)
      redirect_to topic_path(@topic)
    else
      render 'edit'
    end
  end

  def destroy
    if @post.destroy
      redirect_to topic_path(@topic)
    else
      redirect_to topic_path(@topic)
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
    send_reply_emails_to_everyone
    send_creation_email
  end

  def find_collection_of_users(post)
    @all_users_preceding_the_last_user = post.topic.posts.map(&:account)
    @all_users_preceding_the_last_user.pop unless @all_users_preceding_the_last_user.one?
    @all_users_preceding_the_last_user
  end

  def send_reply_emails_to_everyone
    @all_users_preceding_the_last_user.uniq.each do |user|
      PostNotifier.post_replied_notification(user, @user_who_replied, @post).deliver_now
    end
  end

  def send_creation_email
    PostNotifier.post_creation_notification(@user_who_replied, @topic).deliver_now
  end

  def find_relevant_records
    @topic = Topic.where(id: params[:topic_id]).take
    fail ParamRecordNotFound unless @topic
    @forum = @topic.forum
  end

  def find_post_record
    @post = Post.where(id: params[:id]).take
    fail ParamRecordNotFound unless @post
  end

  def find_posts_belonging_to_account
    @account = Account::Find.by_id_or_login(params[:account_id])
    fail ParamRecordNotFound unless @account
    redirect_if_disabled
    @posts = @account.posts.includes(:topic).tsearch(params[:query], parse_sort_term)
             .page(page_param).per_page(10)
  end

  def find_posts
    params[:account_id] ? find_posts_belonging_to_account : find_posts_by_search_params
  end

  def find_posts_by_search_params
    @posts = Post.tsearch(params[:query], parse_sort_term).page(page_param).per_page(10)
  end

  def parse_sort_term
    return Post.where(account_id: @account).respond_to?("by_#{params[:sort]}") ? "by_#{params[:sort]}" : nil if @account
    Post.respond_to?("by_#{params[:sort]}") ? "by_#{params[:sort]}" : nil
  end

  def post_params
    params.require(:post).permit(:body)
  end

  def build_new_post
    post = @topic.posts.build(post_params)
    post.account_id = current_user.id
    post
  end

  def verify_captcha_for_non_admin
    return true if current_user_is_admin?
    verify_recaptcha(model: @post, attribute: :captcha)
  end
end
