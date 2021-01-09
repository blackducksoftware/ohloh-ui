# frozen_string_literal: true

class OhAdmin::JobsController < ApplicationController
  before_action :admin_session_required
  before_action :find_project
  layout 'admin'
  helper JobApiHelper

  def index
    path = 'api/v1/jobs/project_jobs'
    @response = OhlohAnalyticsApi.get_response(path, id: @project.id, page: params[:page] || 1)
  end

  private

  def find_project
    @project = Project.find_by(vanity_url: params[:project_id])
    raise ParamRecordNotFound if @project.nil?
  end
end
