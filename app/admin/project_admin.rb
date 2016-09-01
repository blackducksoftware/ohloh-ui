ActiveAdmin.register Project do
  menu false
  actions :index, :show, :edit, :update

  editable_params = [:uuid, :best_analysis_id]
  permit_params editable_params

  filter :name
  filter :vanity_url
  filter :created_at
  filter :updated_at
  filter :deleted
  filter :user_count

  controller do
    defaults finder: :find_by_vanity_url!
  end

  before_update do |project|
    project.editor_account = current_user
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
    column :uuid
    column :description do |project|
      simple_format project.description
    end
    column :project_security_set do |project|
      link_to project.best_project_security_set_id, admin_project_security_sets_path(project.best_project_security_set)
    end
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      editable_params.each do |attribute|
        f.input attribute
      end
    end

    f.actions
  end
end
