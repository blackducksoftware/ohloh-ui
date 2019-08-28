# frozen_string_literal: true

class FeedbacksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  before_action :set_access_control_header

  def set_access_control_header
    headers['Access-Control-Allow-Origin'] = 'https://security.openhub.net'
  end

  def create
    Feedback.create(feedback_params)
    render nothing: true
  end

  private

  def feedback_params
    params.require(:feedback).permit(:rating, :uuid, :more_info, :project_id, :ip_address, :project_name)
  end
end
