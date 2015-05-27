class ReviewsController < ApplicationController
  helper RatingsHelper
  helper ProjectsHelper
  before_action :session_required, except: [:index, :summary]
  before_action :find_parent, except: :destroy
  before_action :find_review, only: [:edit, :update, :destroy]
  before_action :own_object?, only: [:edit, :update, :destroy]
  before_action :review_context

  def index
    @reviews = @parent.reviews
               .find_by_comment_or_title_or_accounts_login(params[:query])
               .sort_by(params[:sort])
               .paginate(page: params[:page], per_page: 10)
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

  def find_parent
    @parent = @project = Project.from_param(params[:project_id]).take if params[:project_id]
    @parent = @account = Account.from_param(params[:account_id]).take if params[:account_id]
    fail ParamRecordNotFound if @parent.nil?
  end

  def find_review
    @review = Review.find_by_id(params[:id])
    fail ParamRecordNotFound if @review.nil?
  end

  def own_object?
    return true if current_user_is_admin? || @review.account_id == current_user.id
    redirect_to summary_project_reviews_path(@project), flash: { error: t(:not_authorized) }
  end
end
