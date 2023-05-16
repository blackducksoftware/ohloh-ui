# frozen_string_literal: true

ActiveAdmin.register Organization do
  menu false

  actions :index, :show

  filter :name
  filter :vanity_url
  filter :description
  filter :created_at
  filter :updated_at
  filter :projects_count

  controller do
    defaults finder: :find_by_vanity_url
  end

  action_item :jobs, only: :show do
    link_to 'Jobs', admin_organization_analysis_jobs_path(organization)
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
    actions do |organization|
      link_to 'Jobs', admin_organization_analysis_jobs_path(organization)
    end
  end
end
