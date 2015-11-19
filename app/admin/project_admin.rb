ActiveAdmin.register Project do
  menu false
  actions :index, :show

  filter :name
  filter :vanity_url
  filter :created_at
  filter :updated_at
  filter :deleted
  filter :user_count

  controller do
    defaults finder: :find_by_vanity_url!
  end

  action_item :jobs, only: :show do
    link_to 'Jobs', admin_project_jobs_path(project)
  end

  index do
    column :id
    column :name
    column :vanity_url do |project|
      link_to project.vanity_url, project_path(project)
    end
    column :description do |project|
      simple_format project.description
    end
    actions
  end
end
