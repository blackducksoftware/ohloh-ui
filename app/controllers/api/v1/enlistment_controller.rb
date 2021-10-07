# frozen_string_literal: true

class Api::V1::EnlistmentsController < ApplicationController
  include JWTHelper
  skip_before_action :verify_authenticity_token
  before_action :authenticate_jwt
  before_action :get_enlistments, only: [:unsubscribe]

  def unsubscribe
    @enlistments.each do |en|
      en.create_edit.undo!(current_user)
      Enlistment.connection.execute("delete from fis.subscriptions where code_location_id = #{en.code_location_id}")
    end
    render json: 'No Code Locations', status: :success if @enlistments.length.zero?
    render json: @enlistments, status: :ok unless @enlistments.length.zero?
  end

  private

  def get_enlistments
    url = params[:url]
    branch = params[:branch]
    join_string = 'join code_locations on code_location_id = code_locations.id join repositories'\
                  ' on code_locations.repository_id = repositories.id'
    filter_sring = 'code_locations.module_branch_name= ? AND repositories.url=?'
    @enlistments = Enlistment.joins(:project).joins(join_string).where(filter_sring, branch, url)
  end
end
