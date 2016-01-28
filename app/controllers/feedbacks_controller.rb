class FeedbacksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  before_action :cors_preflight_check
  after_action :cors_set_access_control_headers

  # For all responses in this controller, return the CORS access control headers.
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = set_access_control_header
    headers['Access-Control-Allow-Methods'] = 'POST'
    headers['Access-Control-Max-Age'] = '1728000' # in seconds ..48hours (60*60*48)
  end

  # If this is a preflight OPTIONS request, then short-circuit the
  # request, return only the necessary headers and return an empty
  # text/plain.
  def cors_preflight_check
    headers['Access-Control-Allow-Origin'] = set_access_control_header
    headers['Access-Control-Allow-Methods'] = 'POST'
    headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
    headers['Access-Control-Max-Age'] = '1728000' # in seconds ..48hours (60*60*48)
  end

  def set_access_control_header
    check_list_header_array = ['http://localhost:3000', '*.openhub.net']
    check_list_header_array.include?(request.headers['origin']) ? request.headers['origin'] : false
  end

  def create
    Feedback.create(feedback_params)
    render nothing: true
  end

  private

  def feedback_params
    params.require(:feedback).permit(:rating, :uuid, :more_info, :project_name)
  end
end
