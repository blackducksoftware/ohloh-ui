ActiveAdmin.register Job do
  belongs_to :project, :finder => :find_by_url_name!
  permit_params :status, :priority, :wait_until, :current_step_at, :notes
  menu :if => proc{false} # work around for ActiveAdmin::NoMenuError

  index do
    column :type
    column :id do |job|
      link_to job.id, admin_project_job_path(project, job)
    end
    column "Priority:", :priority
    column "Progress" do |job|
      "#{job.current_step? ? job.current_step : '-'} of #{job.max_steps? ? job.max_steps : '-'}"
    end
    column "Log (TO DO)"
    column :status do |job|
      span job.job_status.name
      if job.slave_id
        span "on"
        span link_to job.slave.hostname, admin_slafe_path(job.slave)
      end
    end
    column "Job Owner" do |job|
      if job.project_id
        link_to job.project.name, project_path(job.project)
      end
    end
  end
  
  show do
    render :partial => 'job'
  end

  member_action :reschedule, method: :put do
    p "*********************** PDP Reschedule"
    flash[:success] = "Job has been rescheduled."
    redirect_to admin_project_job_path(params['project_id'], params['id'])
  end

  member_action :rebuild_people, method: :put do
    p "*********************** PDP rebuild_people"
    flash[:success] = "People records for this project have been rebuilt"
    redirect_to admin_project_job_path(params['project_id'], params['id'])
  end

  controller do
    def update
      Job.find(params['id']).update_attributes(permitted_params['job'])
      flash[:success] = "Priority has been updated"
      redirect_to admin_job_path(params['id'])
     end

    def destroy
      p "**************** DESTROY"
    end
  end
end
