# frozen_string_literal: true

class Api::V1::EnlistmentsController < ApplicationController
  helper EnlistmentsHelper
  helper ProjectsHelper

  include JWTHelper

  skip_before_action :verify_authenticity_token
  before_action :authenticate_jwt
  before_action :get_enlistments, only: [:unsubscribe]
  before_action :build_code_location, only: [:enlist]
  before_action :find_project, only: [:enlist]

  def unsubscribe
    @enlistments.each do |en|
      en.create_edit.undo!(current_user)
    end
    render json: 'No Code Locations', status: :success if @enlistments.length.zero?
    render json: @enlistments, status: :ok unless @enlistments.length.zero?
  end

  def enlist
    @code_location.create_enlistment_for_project(current_user, @project)
    render json: @code_location
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

  def build_code_location
    @code_location = CodeLocation.new(code_location_params.merge(client_relation_id: params[:project]))
    render json: 'Unable to create code Location', status: :bad_request unless @code_location.save
  end

  def code_location_params
    params[:code_location] = { 'scm_type' => params[:scm_type], 'url' => params[:url], 'branch' => params[:branch] }
  end

  def find_project
      @project = Project.find params[:project]
    rescue ActiveRecord::RecordNotFound
      render json: 'Project Not Found', status: :bad_request
      return false
    end
  end

  def delete_all_subscriptions(code_location_id)
    Enlistment.connection.execute("DELETE FROM fis.subscriptions WHERE code_location_id =#{code_location_id};")
  end
end
