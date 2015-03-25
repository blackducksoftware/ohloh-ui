class ProjectLicensesController < ApplicationController
  helper ProjectsHelper

  before_action :find_project
  before_action :project_context

  def index
    @licenses = @project.licenses
  end

  def new
    @licenses = License.all
  end

  private

  def find_project
    @project = Project.not_deleted.from_param(params[:project_id]).take
    @project.editor_account = current_user
    fail ParamRecordNotFound unless @project
  end
end
