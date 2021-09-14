# frozen_string_literal: true

class Api::V1::EnlistmentsController < ApplicationController
  include JWTHelper
  skip_before_action :verify_authenticity_token
  before_action :authenticate_jwt

  def unsubscribe
    enlistments = get_enlistments(params[:url], params[:branch])
    render json: enlistments, status: :ok
  end

  def get_enlistments(url, branch)
    join_string = 'join code_locations on code_location_id = code_locations.id'\
                  ' join repositories on code_locations.repository_id = repositories.id'
    filter_string = url + ' ' + branch
    Enlistment.joins(:project).joins(join_string).filter_by(filter_string)
  end
end
