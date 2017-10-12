ActiveAdmin.register Organization do
  menu false

  actions :index, :show, :edit, :update

  editable_params = %w(deleted name vanity_url description homepage_url org_type)
  permit_params editable_params

  filter :name
  filter :vanity_url
  filter :description
  filter :created_at
  filter :updated_at
  filter :deleted
  filter :projects_count

  controller do
    defaults finder: :find_by_vanity_url
  end

  before_update do |organization|
    organization.editor_account = current_user
  end

  action_item :jobs, only: :show do
    link_to 'Jobs', admin_organization_jobs_path(organization)
  end

  index do
    column :id
    column :name
    column :vanity_url
    column(:org_type, &:org_type_label)
    column :homepage_url
    column :created_at
    column :updated_at
    column :projects_count
    column :deleted
    actions do |organization|
      link_to 'Jobs', admin_organization_jobs_path(organization)
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      editable_params.each do |attribute|
        f.input attribute
      end

      text_node "Org type dictionary: #{Organization::ORG_TYPES}"
    end

    f.actions
  end
end
