ActiveAdmin.register Job do
  config.sort_order = 'current_step_at_desc'

  belongs_to :project, finder: :find_by_vanity_url!, optional: true
  belongs_to :organization, finder: :find_by_vanity_url!, optional: true
  belongs_to :account, finder: :find_by_login, optional: true
  belongs_to :failure_group, optional: true

  permit_params :status, :priority, :wait_until, :current_step_at, :notes, :do_not_retry, :retry_count

  filter :slave, collection: proc { Slave.pluck(:hostname).sort }
  filter :type, as: :select
  filter :job_status
  filter :project_vanity_url, as: :string, label: 'PROJECT URL NAME'
  filter :organization_vanity_url, as: :string, label: 'ORGANIZATION VANITY URL'
  filter :account_login, as: :string, label: 'Account Login'
  filter :exception

  scope 'Uncategorized Failed Jobs', :uncategorized_failure_group, if: proc { params[:scope] }

  actions :all, except: :new

  action_item :manually_schedule, only: :index do
    link_to 'Manually Schedule Update',
            manually_schedule_admin_project_jobs_path(project), method: :post if params[:project_id]
  end

  action_item :project_analysis_job, only: :index do
    link_to 'Manually Create Analyze Job',
            analyze_admin_project_jobs_path(project), method: :post if params[:project_id]
  end

  action_item :decategorize do
    link_to 'Decategorize',
            decategorize_admin_failure_group_path(params[:failure_group_id]) if params[:failure_group_id]
  end

  show do
    render partial: 'job'
  end

  member_action :reschedule, method: :put do
    job = Job.find(params[:id])
    if job.running?
      flash[:warning] = 'Cannot schedule a running job.'
    else
      SlaveLog.create!(job: job, message: "Job rescheduled by #{current_user.name}.", level: SlaveLog::INFO)
      job.update_attributes!(status: Job::STATUS_SCHEDULED, slave: nil, exception: nil, backtrace: nil)
      flash[:success] = 'Job has been rescheduled.'
    end
    redirect_to :back
  end

  member_action :rebuild_people, method: :put do
    job = Job.find(params[:id])
    Person.rebuild_by_project_id(job.project_id)
    redirect_to :back, flash: { success: 'People records for this project have been rebuilt' }
  end

  member_action :mark_as_failed, method: :get do
    job = Job.find(params[:id])
    SlaveLog.create(job: job, message: "Job manually failed by #{current_user.login}.",
                    level: SlaveLog::WARNING)
    job.update_attributes(status: Job::STATUS_FAILED)
    job.categorize_failure
    flash[:notice] = "Job #{job.id} marked as failed."
    redirect_to :back
  end

  member_action :recount do
    job = Job.find(params[:id])
    job.update_attributes!(retry_count: 0, wait_until: nil)
    flash[:notice] = "Job #{job.id} retry attempts counter has been reset to 0."
    redirect_to admin_job_path(job)
  end

  controller do
    def scoped_collection
      if params['code_location_id']
        CodeLocation.find(params['code_location_id']).jobs
      elsif params[:project_id]
        project_jobs
      else
        super
      end
    end

    def index
      redirect_to oh_admin_project_jobs_path if params[:project_id]
    end

    def update
      Job.find(params['id']).update_attributes(permitted_params['job'])
      flash[:success] = 'Priority has been updated'
      redirect_to admin_job_path(params['id'])
    end

    def destroy
      flash[:success] = 'Job has been deleted'
      Job.find(params['id']).destroy
      redirect_to admin_jobs_path
    end

    def manually_schedule
      project = Project.find_by_vanity_url!(params[:project_id])
      project.code_locations.each(&:schedule_fetch)
      redirect_to admin_project_jobs_path(project), flash: { success: 'Job has been scheduled.' }
    end

    def analyze
      project = Project.find_by_vanity_url!(params[:project_id])
      AnalyzeJob.create(project: project, priority: 0)
      redirect_to admin_project_jobs_path(project), flash: { success: 'Analysis Job has been created manually.' }
    end

    private

    def project_jobs
      project = Project.find_by_vanity_url!(params[:project_id])
      if project.code_locations.size.zero?
        project.jobs
      else
        code_location_ids = Enlistment.where(project_id: project.id, deleted: false).pluck(:code_location_id)
        Job.where("project_id = #{project.id} or code_location_id in (#{code_location_ids.join(',') || 0})")
      end
    end
  end
end
