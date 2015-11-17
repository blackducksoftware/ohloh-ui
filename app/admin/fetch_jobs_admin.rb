ActiveAdmin.register FetchJob do
  belongs_to :project, finder: :find_by_url_name!, optional: true
  actions :index, :show, :destroy
  menu false

  show do
    attributes_table do
      row :code_sets do
        table do
          tr do
            th 'CodeSet'
            th
            th 'Updated Date'
          end

          fetch_job.repository.code_sets.each do |code_set|
            tr do
              td do
                a "CodeSet #{code_set.id}", href: admin_code_set_path(code_set.id)
                span '(Best)' if code_set.repository.best_code_set_id == code_set.id
                span '(Job)' if fetch_job.code_set_id == code_set.id
              end
              td do
                if fetch_job.code_set_id == code_set.id
                  a '[Fetch]', href: fetch_admin_code_set_path(code_set.id)
                  a '[Re-Import]', href: reimport_admin_code_set_path(code_set.id)
                  a '[Re-sloc]', href: resloc_admin_code_set_path(code_set.id)
                else
                  a '[Fetch]', href: fetch_admin_code_set_path(code_set.id)
                end
              end
              td code_set.updated_on ? time_ago_in_days_hours_minutes(code_set.updated_on) : 'never'
            end
          end
        end
      end

      row :re_fetch do
        repo = fetch_job.repository
        confirm = "Are you sure you want to start a completely new download of #{repo.url} #{repo.branch_name}?"
        link_to 'Re Fetch', refetch_admin_job_path, method: :post, confirm: confirm
      end

      if fetch_job.status == Job::STATUS_RUNNING
        row :fail do
          link_to 'Fail', mark_as_failed_admin_job_path(fetch_job)
        end
      end

      row :enlisted_projects do
        fetch_job.repository.projects.map do |p|
          a p.name, href: project_path(p)
          a '[Jobs]', href: admin_project_jobs_path(p)
        end
      end

      row :repository do
        link_to "Repository #{fetch_job.repository_id}", admin_repository_path(fetch_job.repository_id)
      end

      row :code_set do
        if fetch_job.code_set_id
          link_to "CodeSet #{fetch_job.code_set_id}", admin_code_set_path(fetch_job.code_set_id)
        end
      end

      row :failure_group do
        fetch_job.failure_group.nil? ? 'None' : fetch_job.failure_group.name
      end
    end
  end
end
