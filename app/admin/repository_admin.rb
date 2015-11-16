ActiveAdmin.register Repository do
  actions :show, :index

  filter :url
  filter :module_name
  filter :branch_name
  filter :type, as: :select
  filter :created_at
  filter :updated_at

  action_item only: :show do
    link_to 'Re-Fetch', refetch_admin_repository_path(repository), method: :post
  end

  action_item only: :show do
    link_to 'Jobs', admin_repository_jobs_path(repository)
  end

  action_item only: :show do
    link_to 'CodeSets', admin_repository_code_sets_path(repository)
  end

  index do
    %w(id type url module_name branch_name created_at updated_at).each { |attr| column attr }
    column 'Update Interval' do |repository|
      update_interval = (repository.update_interval < 8.hours) ? 8.hours : repository.update_interval
      "Updates every #{time_ago_in_days_hours_minutes(Time.now - update_interval)}"
    end

    actions do |repository|
      link_to 'Log', admin_repository_slave_logs_path(repository)
    end
  end

  show do
    panel 'Repository Overview' do
      attributes_table_for repository do
        row :type
        row 'url' do
          repository.nice_url
        end
        row 'Update Interval' do
          update_interval = (repository.update_interval < 8.hours) ? 8.hours : repository.update_interval
          "Updates every #{time_ago_in_days_hours_minutes(Time.now - update_interval)}"
        end
        row 'Slave Log' do
          link_to 'Log', admin_repository_slave_logs_path(repository)
        end
        row :best_code_set
        row 'best_sloc_set' do
          repository.best_code_set.best_sloc_set
        end
      end
    end
  end

  sidebar 'Repository Details', only: :show do
    attributes_table_for repository do
      rows(*repository.attribute_names)
    end
  end

  member_action :refetch, method: :post do
    Repository.find(params[:id]).refetch
    redirect_to admin_repository_jobs_path(params[:id]), flash: { success: 'FetchJob has been scheduled' }
  end
end
