ActiveAdmin.register Job do
  config.sort_order = 'current_step_at_desc'

  belongs_to :project, finder: :find_by_vanity_url!, optional: true
  belongs_to :organization, finder: :find_by_vanity_url!, optional: true
  belongs_to :account, finder: :find_by_login, optional: true
  belongs_to :failure_group, optional: true

  permit_params :status, :priority, :wait_until, :current_step_at, :notes, :do_not_retry

  filter :slave, collection: proc { Slave.pluck(:hostname).sort }
  filter :type, as: :select
  filter :job_status
  filter :project_vanity_url, as: :string, label: 'PROJECT URL NAME'
  filter :organization_vanity_url, as: :string, label: 'ORGANIZATION VANITY URL'
  filter :account_login, as: :string, label: 'Account Login'

  actions :all, except: :new

  action_item :manually_schedule, only: :index do
    link_to 'Manually Schedule Update',
            manually_schedule_admin_project_jobs_path(project), method: :post if params[:project_id]
  end

  index do
    column :type
    column :id do |job|
      link_to job.id, admin_job_path(job)
    end
    column 'Priority', :priority
    column :current_step_at
    column 'Last Updated' do |job|
      time_ago_in_words(job.current_step_at) if job.current_step_at
    end
    column 'Progress' do |job|
      "#{job.current_step? ? job.current_step : '-'} of #{job.max_steps? ? job.max_steps : '-'}"
    end
    column :status do |job|
      span job.job_status.try(:name)
      if job.slave_id
        span 'on'
        span link_to job.slave.hostname, admin_slafe_path(job.slave)
      end
    end
    column 'Owners' do |job|
      span link_to "Project #{job.project.name}", project_path(job.project) if job.project_id
      span link_to "Organization #{job.organization.name}", organization_path(job.organization) if job.organization_id
      span link_to "Account #{job.account.login}", account_path(job.account) if job.account_id
      span link_to "Repository #{job.repository_id}", admin_repository_path(job.repository_id) if job.repository_id
    end

    actions defaults: false do |job|
      link_to 'Slave Log', admin_job_slave_logs_path(job)
    end
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
    flash[:notice] = "Job #{ job.id } marked as failed."
    redirect_to :back
  end

  member_action :refetch, method: :post do
    job = Job.find(params[:id])
    job = job.repository.refetch
    flash[:success] = "FetchJob #{job.id} created."
    redirect_to admin_job_path(job)
  end

  member_action :recount do
    job = Job.find(params[:id])
    job.update_attributes!(retry_count: 0, wait_until: nil)
    flash[:notice] = "Job #{ job.id } retry attempts counter has been reset to 0."
    redirect_to admin_job_path(job)
  end

  controller do
    def scoped_collection
      if params['repository_id']
        Repository.find(params['repository_id']).jobs
      elsif params[:project_id]
        project_jobs
      else
        super
      end
    end

    def update
      Job.find(params['id']).update_attributes(permitted_params['job'])
      flash[:success] = 'Priority has been updated'
      redirect_to admin_job_path(params['id'])
    end

    def destroy
      flash[:success] = 'Job has been deleted'
      redirect_to admin_jobs_path
    end

    def manually_schedule
      project = Project.find_by_vanity_url!(params[:project_id])
      project.repositories.each(&:schedule_fetch)
      redirect_to admin_project_jobs_path(project), flash: { success: 'Job has been scheduled.' }
    end

    private

    def project_jobs
      project = Project.find_by_vanity_url!(params[:project_id])
      if project.repositories.size.zero?
        project.jobs
      else
        Job.where("project_id = #{project.id} or repository_id in (
                  select repository_id from enlistments where project_id = #{project.id} and not deleted)")
      end
    end
  end
end
