# frozen_string_literal: true

ActiveAdmin.register Enlistment do
  enlistment_params = 'ignore'
  permit_params enlistment_params
  actions :index, :show, :edit, :update

  filter :project
  filter :repository
  filter :deleted
  filter :created_at
  filter :updated_at
  filter :ignore
  filter :code_location_id

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
