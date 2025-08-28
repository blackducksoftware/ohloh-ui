# frozen_string_literal: true

ActiveAdmin.register Enlistment do
  index do
    selectable_column
    column :id do |enlistment|
      enlistment.id.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
    end
    column :project do |enlistment|
      name = enlistment.project&.name
      name = name.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '') if name
      name
    end
    column :ignore do |enlistment|
      ignore = enlistment.ignore
      ignore = ignore.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '') if ignore
      ignore
    end
    column :deleted
    column :created_at
    column :updated_at
    actions
  end
  menu false
  config.per_page = 10
  enlistment_params = 'ignore'
  permit_params enlistment_params
  actions :index, :show, :edit, :update

  filter :project, collection: -> { Project.active_enlistments }
  filter :repository
  filter :deleted
  filter :created_at
  filter :updated_at
  filter :ignore

  before_update do |enlistment|
    enlistment.editor_account = current_user
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs 'Details' do
      f.input :ignore, as: :text
    end
    f.actions
  end
end
