class RatingsController < ApplicationController
  before_action :session_required
  before_action :find_project_and_rating

  def rate
    @rating.assign_attributes(score: params[:score])
    render nothing: true, status: (@rating.save ? :ok : :unprocessable_entity)
  end

  def unrate
    @rating.destroy if @rating.persisted?
    render nothing: true, status: :ok
  end

  private

  def model_params
    params.permit([:score])
  end

  def find_project_and_rating
    @project = Project.find_by_url_name!(params[:id])
    @rating = Rating.where(project_id: @project.id, account_id: current_user.id).first_or_initialize
  rescue ActiveRecord::RecordNotFound
    raise ParamRecordNotFound
  end
end
