class RatingsController < ApplicationController
  ALLOWED_PARTIALS = ['projects/show/community_rating', 'reviews/rater']
  before_action :session_required
  before_action :find_project_and_rating

  def rate
    @rating.assign_attributes(model_params)
    @rating.save
    sanitize_partial(params[:show])
    render partial: @partial, locals: { score: @rating.score, project: @project.reload }
  end

  def unrate
    @rating.destroy if @rating.persisted?
    @rating = nil if @rating.destroyed?
    sanitize_partial(params[:show])
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

  def sanitize_partial(partial)
    if ALLOWED_PARTIALS.include? partial
      @partial = partial
    else
      fail StandardError, I18n.t('ratings.partial_not_found', partial: partial)
    end
  end
end
