class ReviewsController < ApplicationController
  helper RatingsHelper
  helper ProjectsHelper

  before_action :session_required, :redirect_unverified_account, except: %i[index summary]
  before_action :set_project_or_fail, except: :destroy, if: -> { params[:project_id] }
  before_action :set_account, except: :destroy, if: -> { params[:account_id] }
  before_action :find_review, only: %i[edit update destroy]
  before_action :own_object?, only: %i[edit update destroy]
  before_action :review_context

  def index
    # rubocop:disable Rails/DynamicFindBy # find_by... here is a predefined scope.
    @reviews = @parent.reviews
                      .find_by_comment_or_title_or_accounts_login(params[:query])
                      .sort_by(params[:sort])
                      .paginate(page: page_param, per_page: 10)
    # rubocop:enable Rails/DynamicFindBy
  end

  def summary
    @account_reviews = current_user.reviews.where(project: @project) if logged_in?
    @most_helpful_reviews = @parent.reviews.top(5)
    @recent_reviews = @parent.reviews.sort_by('recently_added').limit(5)
    @rating = logged_in? ? current_user.ratings.where(project_id: @project).take : nil
  end

  def new
    @review = Review.new
    @rating = current_user.ratings.where(project_id: @project).take
  end

  def create
    @review = @parent.reviews.build(review_params)
    @review.account = current_user
    if @review.save
      redirect_to summary_project_reviews_path(@project), flash: { success: t('.success') }
    else
      flash.now[:error] = t('.error')
      render :new
    end
  end

  def edit
    @rating = current_user.ratings.where(project_id: @project).take
  end

  def update
    if @review.update(review_params)
      redirect_to summary_project_reviews_path(@project), flash: { success: t('.success') }
    else
      @rating = current_user.ratings.where(project_id: @project).take
      flash.now[:error] = t('.error')
      render :edit
    end
  end

  def destroy
    project = @review.project
    @review.destroy
    redirect_to summary_project_reviews_path(project)
  end

  private

  def review_params
    params.require(:review).permit(:title, :comment)
  end

  def set_project_or_fail
    super
    @parent = @project
  end

  def set_account
    @parent = @account = Account.from_param(params[:account_id]).take
    raise ParamRecordNotFound if @parent.nil?
  end

  def find_review
    @review = Review.find_by(id: params[:id])
    raise ParamRecordNotFound if @review.nil?
  end

  def own_object?
    return true if current_user_is_admin? || @review.account_id == current_user.id
    redirect_to summary_project_reviews_path(@project), flash: { error: t(:not_authorized) }
  end
end
