class TopicsController < ApplicationController
  helper MarkdownHelper
  before_action :session_required, :redirect_unverified_account, only: [:new, :create, :close, :reopen]
  before_action :admin_session_required, only: [:edit, :update, :close]
  before_action :find_forum_record, only: [:new, :create]
  before_action :find_forum_and_topic_records, except: [:index, :new, :create]
  before_action :must_be_admin_or_topic_creator, only: [:destroy, :reopen]
  after_action :track_views, only: [:show]

  def index
    if params[:forum_id]
      find_forum_record
      @topics = @forum.topics
      redirect_to forum_path(@forum)
    else
      redirect_to forums_path
    end
  end

  def new
    @topic = @forum.topics.build
    @post = @topic.posts.build
    redirect_to new_session_path unless logged_in?
  end

  def create
    @topic = build_new_topic
    if verify_captcha_for_non_admin && @topic.save
      redirect_to forum_path(@forum)
    else
      render :new
    end
  end

  def show
    @posts = @topic.posts.paginate(page: page_param, per_page: TopicDecorator::PER_PAGE)
    @post = Post.new

    render 'show.atom.builder' if request.format.rss?
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

  def close
    @topic.update!(closed: true)
    redirect_to topic_path(@topic)
  end

  def reopen
    @topic.update!(closed: false)
    redirect_to topic_path(@topic)
  end

  private

  def track_views
    topic = Topic.where(id: params[:id]).take
    fail ParamRecordNotFound unless topic
    topic.increment!(:hits) unless logged_in? && (@topic.account == current_user)
  end

  def find_forum_record
    @forum = Forum.where(id: params[:forum_id]).take
    fail ParamRecordNotFound unless @forum
  end

  def find_forum_and_topic_records
    @topic = Topic.where(id: params[:id]).take
    fail ParamRecordNotFound unless @topic
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

  def must_be_admin_or_topic_creator
    access_denied unless current_user_is_admin? || @topic.account == current_user
  end

  def verify_captcha_for_non_admin
    return true if current_user_is_admin?
    verify_recaptcha(model: @topic)
  end
end
