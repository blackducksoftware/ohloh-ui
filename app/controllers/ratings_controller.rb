class RatingsController < ApplicationController
  ALLOWED_PARTIALS = ['projects/show/community_rating', 'reviews/rater']
  before_action :session_required
  before_action :find_project_and_rating
  before_action :sanitize_partial, only: [:rate, :unrate]

  def rate
    @rating.assign_attributes(model_params)
    @rating.save
    render partial: @partial, locals: { score: @rating.score, project: @project.reload }
  end

  def unrate
    @rating.destroy if @rating.persisted?
    render partial: @partial, locals: { score: '0' }
  end

  private

  def model_params
    params.permit(:score)
  end

  def find_project_and_rating
    @project = Project.find_by_url_name!(params[:id])
    @rating = Rating.where(project_id: @project.id, account_id: current_user.id).first_or_initialize
  rescue ActiveRecord::RecordNotFound
    raise ParamRecordNotFound
  end

  def sanitize_partial
    if ALLOWED_PARTIALS.include? params[:show]
      @partial = params[:show]
    else
      fail StandardError, I18n.t('ratings.partial_not_found', partial: params[:show])
    end
  end
end
