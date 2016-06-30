class EnlistmentsController < SettingsController
  helper EnlistmentsHelper
  helper ProjectsHelper

  include EnlistmentFilters

  def index
    @enlistments = @project.enlistments
                           .includes(:project, :repository)
                           .filter_by(params[:query])
                           .send(parse_sort_term)
                           .paginate(page: page_param, per_page: 10)
    @failed_jobs = Enlistment.with_failed_repository_jobs.where(id: @enlistments.map(&:id)).any?
  end

  def show
    respond_to do |format|
      format.xml
    end
  end

  def new
    @repository = Repository.new
    @enlistment = Enlistment.new
  end

  def create
    initialize_repository
    return render :new, status: :unprocessable_entity unless @repository.valid?
    save_or_update_repository
    create_enlistment
    flash[:show_first_enlistment_alert] = true if @project.enlistments.count == 1
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
    redirect_to project_enlistments_path(@project), flash: { success: t('.success', name: @project.name) }
  end
end
