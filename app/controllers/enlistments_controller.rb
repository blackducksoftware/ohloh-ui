# frozen_string_literal: true

class EnlistmentsController < SettingsController
  helper EnlistmentsHelper
  helper ProjectsHelper

  include EnlistmentFilters

  before_action :set_enlistments, only: :index

  # TODO: Remove dependence on code_locations table here.
  def index
    @stale_jobs_report = FisJob.stale_jobs_report(@project.enlistments
      .joins('join code_locations on code_location_id = code_locations.id'))
  end

  def show
    respond_to do |format|
      format.xml
    end
  end

  def new
    @code_location = CodeLocation.new
    @enlistment = Enlistment.new
  end

  def create
    if @code_location.save
      create_enlistment
      set_flash_message
      redirect_to project_enlistments_path(@project)
    else
      flash[:error] = @code_location.errors['error']
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @examples = @enlistment.ignore_examples
  end

  def edit_allowed_files
    @examples = @enlistment.ignore_examples
  end

  def update
    @enlistment.update(enlistment_params)
    @enlistment.project.schedule_delayed_analysis(3.minutes)
    redirect_to project_enlistments_path(@project), flash: { success: t('.success') }
  end

  def destroy
    @enlistment.create_edit.undo!(current_user)
    redirect_to project_enlistments_path(@project), flash: { success: t('.success', name: @project.name) }
  end

  private

  def set_enlistments
    @enlistments = @project.enlistments.joins(:project)
                           .joins('join code_locations on code_location_id = code_locations.id
                                   join repositories on code_locations.repository_id = repositories.id')
                           .filter_by(params[:query]).send(parse_sort_term)
                           .by_dnf(params[:dnf])
                           .paginate(page: page_param, per_page: 10)
  end

  def create_enlistment
    @code_location.create_enlistment_for_project(current_user, @project)
  end

  def set_flash_message
    flash[:show_first_enlistment_alert] = true if @project.enlistments.count == 1
    flash[:success] = t('.success', url: @code_location.url,
                                    module_branch_name: (CGI.escapeHTML @code_location.branch.to_s))
  end

  def code_location_params
    params[:code_location].select { |k, _v| %w[url branch scm_type].include?(k) }
  end
end
