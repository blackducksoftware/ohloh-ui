class HelpfulsController < ApplicationController
  before_action :session_required
  before_action :find_parents_and_helpful

  def create
    @helpful.assign_attributes(model_params)
    @helpful.save
    render json: { yes: @review.helpfuls.positive.count, total: @review.helpfuls.count }.to_json
  end

  private

  def model_params
    params.require(:helpful).permit(:yes)
  end

  def find_parents_and_helpful
    @project = Project.find_by_url_name!(params[:project_id])
    @review = Review.find_by_project_id_and_id!(@project.id, params[:review_id])
    @helpful = Helpful.where(review_id: @review.id, account_id: current_user.id).first_or_initialize
  rescue ActiveRecord::RecordNotFound
    raise ParamRecordNotFound
  end
end
