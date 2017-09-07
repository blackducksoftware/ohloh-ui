ActiveAdmin.register CodeLocation do
  actions :index, :show, :update
  filter :module_branch_name
  filter :repository_url, as: :string
  filter :repository_type, as: :select, collection: proc { Repository.subclasses.map(&:name) }
  permit_params :status, :update_interval, :module_branch_name, repository_attributes: [:type, :url]

  action_item :refetch, only: :show do
    link_to 'Re-Fetch', refetch_admin_code_location_path(code_location)
  end

  action_item :jobs, only: :show do
    link_to 'Jobs', admin_code_location_jobs_path(code_location)
  end

  action_item :code_sets, only: :show do
    link_to 'CodeSets', admin_code_location_code_sets_path(code_location)
  end

  index do
    column :id
    column :repository_type do |code_location|
      code_location.repository.type
    end
    column :repository_url do |code_location|
      code_location.repository.url
    end
    column :module_branch_name
    column :status do |code_location|
      if code_location.status == 1
        'Active'
      elsif code_location.status == 2
        'Deleted'
      else
        'Undefined'
      end
    end
    column :created_at
    column :updated_at
    column :repository do |code_location|
      link_to code_location.repository.id, admin_repository_path(code_location.repository)
    end

    actions do |code_location|
      link_to 'Log', admin_code_location_slave_logs_path(code_location)
    end
  end

  show do
    render 'admin/repositories/repository', code_location: code_location, code_sets: code_location.code_sets
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs 'Edit Code Location' do
      f.semantic_fields_for :repository do |repo|
        repo.input :url, as: :string, label: t('admins.code_location.form.repo_url')
        repo.input :type, as: :select, label: t('admins.code_location.form.repo_type'),
                          include_blank: false,
                          collection: Repository.subclasses.map(&:name)
      end
      f.input :module_branch_name, as: :string
      f.input :status
      f.input :update_interval
    end
    f.actions
  end

  sidebar 'CodeLocation Details', only: :show do
    attributes_table_for code_location do
      rows(*code_location.attribute_names)
    end
  end

  member_action :refetch do
    CodeLocation.find(params[:id]).refetch
    redirect_to admin_code_location_jobs_path(params[:id]), flash: { success: 'FetchJob has been scheduled' }
  end
end
