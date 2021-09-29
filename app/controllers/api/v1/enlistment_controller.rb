# frozen_string_literal: true

class Api::V1::EnlistmentsController < ApplicationController
  include JWTHelper
  skip_before_action :verify_authenticity_token
  before_action :authenticate_jwt

  def unsubscribe
    enlistments = get_enlistments(params[:url], params[:branch])
    enlistments.each do |en|
      # en.create_edit.undo!(current_user)
      # delete_subscription(en.project_id, en.code_location_id)
      # ActiveRecord::Base.connection.execute("delete from fis.subscriptions where code_location_id IN (#{c_ids.join(',')});"
    end
    render json: enlistments, status: :ok
  end

  def get_enlistments(url, branch)
    join_string = 'join code_locations on code_location_id = code_locations.id join repositories on code_locations.repository_id = repositories.id'
    Enlistment.joins(:project).joins(join_string).where('code_locations.module_branch_name= ? AND repositories.url=?', branch, url)
  end
end
