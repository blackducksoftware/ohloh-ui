class DuplicatesController < ApplicationController
  helper ProjectsHelper

  before_action :session_required
  before_action :find_project
  before_action :find_duplicate, only: [:edit, :update, :destroy]
  before_action :project_context

  def new
    previous_dupe = @project.duplicates.first
    if previous_dupe
      flash[:notice] = t('.cant_dupe_a_dupe', this: @project.name, that: previous_dupe.bad_project.name)
      return redirect_to project_path(@project)
    end
    @duplicate = Duplicate.new(bad_project: @project)
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def find_project
    @project = Project.from_param(params[:project_id]).take
    fail ParamRecordNotFound if @project.nil?
  end

  def find_duplicate
    @duplicate = Duplicate.where(project_id: @project.id, account_id: current_user.id).from_param(params[:id]).take
    fail ParamRecordNotFound if @duplicate.nil?
  end
end
