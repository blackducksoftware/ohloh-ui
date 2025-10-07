# frozen_string_literal: true

ActiveAdmin.register Job do
  menu false
  config.sort_order = 'current_step_at_desc'

  belongs_to :project, finder: :find_by_vanity_url!, optional: true
  belongs_to :organization, finder: :find_by_vanity_url!, optional: true
  belongs_to :account, finder: :find_by_login, optional: true
  belongs_to :failure_group, optional: true

  permit_params :status, :priority, :wait_until, :current_step_at, :notes, :do_not_retry, :retry_count

  filter :worker, collection: proc { Worker.pluck(:hostname).sort }
  filter :type, as: :select
  filter :job_status
  filter :project_vanity_url, as: :string, label: 'PROJECT URL NAME'
  filter :organization_vanity_url, as: :string, label: 'ORGANIZATION VANITY URL'
  filter :account_login, as: :string, label: 'Account Login'
  filter :exception

  scope 'Uncategorized Failed Jobs', :uncategorized_failure_group, if: proc { params[:scope] }

  actions :all, except: :new

  action_item :decategorize do
    if params[:failure_group_id]
      link_to 'Decategorize', decategorize_admin_failure_group_path(params[:failure_group_id])
    end
  end

  show do
    render partial: 'job'
  end

  member_action :reschedule, method: :put do
    job = Job.find(params[:id])
    if job.running?
      flash[:warning] = I18n.t('oh_admin.jobs.cannot_schedule_running')
    else
      WorkerLog.create!(job: job, message: "Job rescheduled by #{current_user.name}.", level: WorkerLog::INFO)
      job.update!(status: Job::STATUS_SCHEDULED, worker: nil, exception: nil, backtrace: nil)
      flash[:success] = I18n.t('oh_admin.jobs.rescheduled')
    end
    redirect_to_saved_path
  end

  member_action :rebuild_people, method: :put do
    job = Job.find(params[:id])
    Person.rebuild_by_project_id(job.project_id)
    redirect_to_saved_path(flash: { success: 'People records for this project have been rebuilt' })
  end

  member_action :mark_as_failed, method: :get do
    job = Job.find(params[:id])
    WorkerLog.create(job: job, message: "Job manually failed by #{current_user.login}.",
                     level: WorkerLog::WARNING)
    job.update(status: Job::STATUS_FAILED)
    job.categorize_failure
    flash[:notice] = "Job #{job.id} marked as failed."
    redirect_to_saved_path
  end

  member_action :recount do
    job = Job.find(params[:id])
    job.update!(retry_count: 0, wait_until: nil)
    flash[:notice] = "Job #{job.id} retry attempts counter has been reset to 0."
    redirect_to admin_job_path(job)
  end

  controller do
    def scoped_collection
      if params['code_location_id']
        FisJob.where(code_location_id: params['code_location_id'])
      else
        super
      end
    end

    def index
      params[:project_id] ? redirect_to(oh_admin_project_jobs_path) : super
    end

    def update
      Job.find(params['id']).update(permitted_params['job'])
      flash[:success] = I18n.t('oh_admin.jobs.priority_updated')
      redirect_to admin_job_path(params['id'])
    end

    def destroy
      flash[:success] = I18n.t('oh_admin.jobs.deleted')
      Job.find(params['id']).destroy
      redirect_to admin_jobs_path
    end
  end
end
