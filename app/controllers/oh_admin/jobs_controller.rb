class OhAdmin::JobsController < ApplicationController
  before_action :admin_session_required
  before_action :find_project
  layout 'admin'
  helper JobApiHelper

  def index
    @response = JSON.parse(JobApi.new(@project.id, params[:page]).fetch)
  end

  private

  def find_project
    @project = Project.find_by_vanity_url(params[:project_id])
    raise ParamRecordNotFound if @project.nil?
  end
end
