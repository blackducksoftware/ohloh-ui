class OhAdmin::JobsController < ApplicationController
  before_action :admin_session_required
  before_action :find_project
  layout 'admin'
  helper JobApiHelper

  def index
    @response = JSON.parse(ApiJob.new(@project.id, params[:page]).get)
    numbers = (1..@response['total_entries']).to_a
    @pagination = numbers.paginate(page: @response['current_page'], per_page: @response['per_page'])
  end

  private

  def find_project
    @project = Project.find_by_vanity_url(params[:project_id])
    raise ParamRecordNotFound if @project.nil?
  end
end
