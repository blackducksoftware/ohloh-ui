ActiveAdmin.register CompleteJob do
  belongs_to :project, finder: :find_by_url_name!, optional: true
  actions :index, :show, :edit, :destroy
  menu false
  filter :none

  show do
    attributes_table do
      row :code_set do
        if complete_job.code_set_id
          link_to "CodeSet #{complete_job.code_set_id}", admin_code_set_path(complete_job.code_set_id)
        end
      end

      row :repository do
        link_to "Repository #{complete_job.repository_id}", admin_repository_path(complete_job.repository_id)
      end

      row :failure_group do
        complete_job.failure_group.nil? ? 'None' : complete_job.name
      end

      row :re_fetch do
        repo = complete_job.repository
        confirm = "Are you sure you want to start a completely new download of #{repo.url} #{repo.branch_name}?"
        link_to 'Re Fetch', refetch_admin_job_path, method: :post, confirm: confirm
      end

      if complete_job.status == Job::STATUS_RUNNING
        row :fail do
          link_to 'Fail', mark_as_failed_admin_job_path(complete_job)
        end
      end

      row :enlisted_projects do
        complete_job.repository.projects.map do |p|
          a p.name, href: project_path(p)
          a '[Jobs]', href: admin_project_jobs_path(p)
        end
      end
    end
  end
end
