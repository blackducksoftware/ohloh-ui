ActiveAdmin.register SlocJob do
  belongs_to :project, finder: :find_by_url_name!, optional: true
  actions :index, :show, :destroy
  menu false

  show do
    attributes_table do
      row :sloc_sets do
        table do
          tr do
            th 'SlocSet'
            th 'Updated Date'
            th 'As Of'
          end

          sloc_job.repository.best_code_set.sloc_sets.each do |sloc_set|
            tr do
              td do
                span sloc_set.id
                span '(Best)' if sloc_set.code_set.best_sloc_set_id == sloc_set.id
                span '(Job)' if sloc_job.sloc_set_id == sloc_set.id
              end
              td sloc_set.updated_on ? time_ago_in_days_hours_minutes(sloc_set.updated_on) : 'never'
              td sloc_set.as_of || 'nil'
            end
          end
        end
      end

      if sloc_job.status == Job::STATUS_RUNNING
        row :fail do
          link_to 'Fail', mark_as_failed_admin_job_path(sloc_job)
        end
      end

      row :enlisted_projects do
        sloc_job.repository.projects.map do |p|
          a p.name, href: project_path(p)
          a '[Jobs]', href: admin_project_jobs_path(p)
        end
      end

      row :repository do
        link_to "Repository #{sloc_job.repository_id}", admin_repository_path(sloc_job.repository_id)
      end

      row :failure_group do
        sloc_job.failure_group.nil? ? 'None' : sloc_job.failure_group.name
      end
    end
  end
end
