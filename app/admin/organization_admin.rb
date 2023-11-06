# frozen_string_literal: true

ActiveAdmin.register Organization do
  organization_params = %i[name vanity_url org_type description homepage_url]
  permit_params organization_params
  actions :index, :show, :edit, :update

  filter :name
  filter :vanity_url
  filter :description
  filter :created_at
  filter :updated_at
  filter :projects_count

  before_update do |organization|
    organization.editor_account = current_user
  end

  controller do
    defaults finder: :find_by_vanity_url
  end

  index do
    column :id
    column :name
    column :vanity_url
    column(:org_type, &:org_type_label)
    column :homepage_url
    column :projects_count
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs 'Details' do
      f.input :name, as: :text
      f.input :vanity_url, as: :text
      f.input :description, as: :text
      f.input :org_type
      f.input :homepage_url, as: :text
    end
    f.actions
  end
end
