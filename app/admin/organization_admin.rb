ActiveAdmin.register Organization do
  menu false

  actions :index, :show

  filter :name
  filter :url_name
  filter :description
  filter :created_at
  filter :updated_at
  filter :projects_count

  controller do
    defaults finder: :find_by_url_name
  end

  action_item :jobs, only: :show do
    link_to 'Jobs', admin_organization_jobs_path(organization)
  end

  index do
    column :id
    column :name
    column :url_name
    column(:org_type) { |org| org.org_type_label }
    column :homepage_url
    column :created_at
    column :updated_at
    column :projects_count
    actions do |organization|
      link_to 'Jobs', admin_organization_jobs_path(organization)
    end
  end
end
