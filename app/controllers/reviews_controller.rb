class ReviewsController < ApplicationController
  before_action :session_required, except: [:index, :summary]
  before_action :find_parent
  before_action :find_review, only: [:edit, :update, :destroy]
  before_action :review_context, only: [:summary, :index, :new, :edit]

  def index
    @reviews = @parent.reviews
               .includes(:account)
               .find_by_comment_or_title_or_accounts_login(params[:query])
               .sort_by(params[:sort])
               .paginate(page: params[:page], per_page: 10)
  end

  def summary
    @account_reviews = current_user.reviews if logged_in?
    @most_helpful_reviews = @parent.reviews.top(5)
    @recent_reviews = @parent.reviews.sort_by('recently_added').limit(5)
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
      redirect_to new_project_review_path(@project), flash: { error: t('.error') }
    end
  end

  def edit
    @rating = current_user.ratings.where(project_id: @project).take
  end

  def update
    @review.update(review_params)
    redirect_to summary_project_reviews_path(@project), flash: { success: t('.success') }
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
    @parent = if params[:project_id]
                @project = Project.from_param(params[:project_id]).first!
              elsif params[:account_id]
                @account = Account.from_param(params[:account_id]).first!
              end
  rescue ActiveRecord::RecordNotFound
    raise ParamRecordNotFound
  end

  def find_review
    @review = Review.find_by_id(params[:id])
    fail ParamRecordNotFound if @review.nil?
  end
end
