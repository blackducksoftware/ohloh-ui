class DuplicatesController < ApplicationController
  helper ProjectsHelper

  before_action :session_required
  before_action :find_project
  before_action :find_duplicate, only: [:edit, :update, :destroy]
  before_action :find_good_project, only: [:create, :update]
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
    @duplicate = Duplicate.new(good_project: @good_project, bad_project: @project, comment: duplicate_params[:comment])
    if @duplicate.save
      flash[:success] = t('.success')
      redirect_to project_path(@duplicate.bad_project)
    else
      render :new, status: :unprocessable_entity
    end
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

  def find_good_project
    @good_project = Project.from_param(duplicate_params[:good_project_id]).take
    fail ParamRecordNotFound if @good_project.nil?
  end

  def duplicate_params
    params.require(:duplicate).permit([:good_project_id, :comment])
  end
end
