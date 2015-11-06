ActiveAdmin.register Job do
  belongs_to :project, :finder => :find_by_url_name!, :optional => true
  belongs_to :repository, :optional => true
  permit_params :status, :priority, :wait_until, :current_step_at, :notes
  menu false
  filter :slave, only: :index, collection: proc {Slave.pluck(:hostname).sort}

  index do
    column :type
    column :id do |job|
      link_to job.id, admin_project_job_path(project, job)
    end
    column "Priority", :priority
    column "Last Updated" do |job|
      time_ago_in_words(job.current_step_at)
    end 
    column "Progress" do |job|
      "#{job.current_step? ? job.current_step : '-'} of #{job.max_steps? ? job.max_steps : '-'}"
    end
    column :status do |job|
      span job.job_status.name
      if job.slave_id
        span "on"
        span link_to job.slave.hostname, admin_slafe_path(job.slave)
      end
    end
    column "Owners" do |job|
      if job.project_id
        span link_to job.project.name, project_path(job.project)
      end
      if job.repository_id
        span link_to "Repository #{job.repository_id}", admin_repository_path(job.repository_id)
      end
    end
    column "Log" do |job|
      span link_to "Slave Log", admin_job_slave_logs_path(job)
    end
  end
  
  show do
    render :partial => 'job'
  end

  member_action :reschedule, method: :put do
    p "*********************** PDP Reschedule"
    flash[:success] = "Job has been rescheduled."
    #redirect_to admin_project_job_path(params['project_id'], params['id'])
    redirect_to :back
  end

  member_action :rebuild_people, method: :put do
    p "*********************** PDP rebuild_people"
    flash[:success] = "People records for this project have been rebuilt"
    #redirect_to admin_project_job_path(params['project_id'], params['id'])
    redirect_to :back
  end

  controller do
    def scoped_collection
      if params['project_id']
        project = Project.find_by_url_name(params['project_id'])
        # This preserves the CollectionProxy class
        project.jobs << project.repositories.collect(&:jobs).first
      elsif params['id']
        #Job.find(params['id'])
        Job
      end
    end

    def update
      Job.find(params['id']).update_attributes(permitted_params['job'])
      flash[:success] = "Priority has been updated"
      redirect_to admin_job_path(params['id'])
     end

    def destroy
      job = Job.find(params['id'])
      p "**************** DESTROY"
      flash[:success] = "Job has been deleted"
      if job.project_id
        redirect_to admin_project_jobs_path(job.project)
      elsif job.repository_id
        redirect_to admin_repository_path(job.repository)
      end
    end
  end
end
