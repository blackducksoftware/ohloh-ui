class EnlistmentsController < SettingsController
  helper EnlistmentsHelper
  helper ProjectsHelper

  include EnlistmentFilters

  def index
    @enlistments = @project.enlistments.includes(:project, code_location: :repository)
                           .filter_by(params[:query]).send(parse_sort_term)
                           .paginate(page: page_param, per_page: 10)
    @failed_jobs = Enlistment.failed_code_location_jobs.where(id: @enlistments.pluck(:id)).any?
  end

  def show
    respond_to do |format|
      format.xml
    end
  end

  def new
    @repository = Repository.new
    @code_location = CodeLocation.new
    @enlistment = Enlistment.new
  end

  def create
    @code_location.save!
    create_enlistment
    manage_code_location_subscription('create')
    set_flash_message
    redirect_to project_enlistments_path(@project)
  end

  def edit
    @examples = @enlistment.ignore_examples
  end

  def update
    @enlistment.update(enlistment_params)
    @enlistment.project.schedule_delayed_analysis(3.minutes)
    redirect_to project_enlistments_path(@project), flash: { success: t('.success') }
  end

  def destroy
    @enlistment.create_edit.undo!(current_user)
    manage_code_location_subscription('delete')
    redirect_to project_enlistments_path(@project), flash: { success: t('.success', name: @project.name) }
  end

  private

  def code_location_params
    params.require(:code_location).permit(:module_branch_name, :bypass_url_validation) if params[:code_location]
  end

  def create_enlistment
    @code_location.create_enlistment_for_project(current_user, @project)
  end

  def set_flash_message
    flash[:show_first_enlistment_alert] = true if @project.enlistments.count == 1
    flash[:success] = t('.success', url: @repository.url,
                                    module_branch_name: (CGI.escapeHTML @code_location.module_branch_name.to_s))
  end

  def manage_code_location_subscription(manage)
    code_location_id = @code_location.try(:id) || @enlistment.code_location_id
    CodeLocationSubscription.new(code_location_id).send(manage)
  end
end
