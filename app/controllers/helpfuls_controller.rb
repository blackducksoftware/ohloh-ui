class HelpfulsController < ApplicationController
  before_action :session_required, :redirect_unverified_account
  before_action :set_project

  def create
    @helpful = Helpful.where(model_params).first_or_initialize
    @helpful.yes = params[:yes].present?
    @helpful.save
  end

  private

  def model_params
    params.require(:helpful).permit(:account_id, :review_id)
  end

  def set_project
    @project = Project.from_param(params[:project_id]).first
    fail ParamRecordNotFound if @project.nil?
  end
end
