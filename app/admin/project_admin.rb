ActiveAdmin.register Project do
  menu false
  actions :index, :show

  filter :name
  filter :url_name
  filter :created_at
  filter :updated_at
  filter :deleted
  filter :user_count

  controller do
    defaults finder: :find_by_url_name!
  end

  action_item only: :show do
    link_to 'Jobs', admin_project_jobs_path(project)
  end

  index do
    column :id
    column :name
    column :url_name do |project|
      link_to project.url_name, project_path(project)
    end
    column :description do |project|
      simple_format project.description
    end
    actions
  end
end
