class TopicsController < ApplicationController
  helper MarkdownHelper
  before_action :session_required, :redirect_unverified_account, only: %i[new create close reopen]
  before_action :admin_session_required, only: %i[edit update close]
  before_action :set_account, :must_own_account, only: :create
  before_action :find_forum_record, only: %i[new create]
  before_action :find_forum_and_topic_records, except: %i[index new create]
  before_action :must_be_admin_or_topic_creator, only: %i[destroy reopen]
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
    @topic = @forum.topics.build(account: current_user)
    @post = @topic.posts.build(account: current_user)
    redirect_to new_session_path unless logged_in?
  end

  def create
    @topic = Topic.new(topic_params)
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
    flash[:notice] = t('.success', topic_title: @topic.title) if @topic.destroy
    redirect_to forums_path
  end

  def close
    @topic.update!(closed: true)
    redirect_to topic_path(@topic)
  end

  def reopen
    @topic.update!(closed: false)
    redirect_to topic_path(@topic)
  end

  def edit; end

  private

  def track_views
    topic = Topic.where(id: params[:id]).take
    raise ParamRecordNotFound unless topic

    # rubocop:disable Rails/SkipsModelValidations # We want to skip validations here.
    topic.increment!(:hits) unless logged_in? && (@topic.account == current_user)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def find_forum_record
    @forum = Forum.where(id: params[:forum_id]).take
    raise ParamRecordNotFound unless @forum
  end

  def find_forum_and_topic_records
    @topic = Topic.where(id: params[:id]).take
    raise ParamRecordNotFound unless @topic

    @forum = @topic.forum
  end

  def topic_params
    params.require(:topic).permit(:forum_id, :account_id, :title, :sticky,
                                  :hits, :closed, posts_attributes: %i[body account_id])
  end

  def must_be_admin_or_topic_creator
    access_denied unless current_user_is_admin? || @topic.account == current_user
  end

  def verify_captcha_for_non_admin
    return true if current_user_is_admin?

    verify_recaptcha(model: @topic)
  end

  def set_account
    account_id = topic_params[:account_id] if topic_and_post_account_id_match?
    @account = Account.from_param(account_id).take
  end

  def topic_and_post_account_id_match?
    topic_params[:account_id] == topic_params[:posts_attributes]['0'][:account_id]
  end
end
