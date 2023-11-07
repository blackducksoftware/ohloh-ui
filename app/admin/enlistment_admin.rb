# frozen_string_literal: true

ActiveAdmin.register Enlistment do
  config.per_page = 10
  enlistment_params = 'ignore'
  permit_params enlistment_params
  actions :index, :show, :edit, :update

  filter :project, collection: Project.active_enlistments
  filter :repository
  filter :deleted
  filter :created_at
  filter :updated_at
  filter :ignore

  before_update do |enlistment|
    enlistment.editor_account = current_user
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs 'Details' do
      f.input :ignore, as: :text
    end
    f.actions
  end
end
