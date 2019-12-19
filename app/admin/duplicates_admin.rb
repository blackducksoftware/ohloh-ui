# frozen_string_literal: true

ActiveAdmin.register Duplicate do
  actions :index, :show
  filter :resolved

  index do
    column :id, sortable: :id do |duplicate|
      if duplicate.resolved?
        link_to duplicate.id, admin_duplicate_path(duplicate), target: '_blank', rel: 'noopener'
      else
        link_to duplicate.id, duplicate_path(duplicate), target: '_blank', rel: 'noopener'
      end
    end

    column :bad_project do |duplicate|
      link_to duplicate.bad_project.name, project_path(duplicate.bad_project)
    end

    column :good_project do |duplicate|
      link_to duplicate.good_project.name, project_path(duplicate.good_project)
    end

    column :reported_by do |duplicate|
      div do
        span { link_to duplicate.account.name, account_path(duplicate.account) } if duplicate.account_id
        span { "#{time_ago_in_words(duplicate.created_at)} #{I18n.t(:ago)}" }
      end
    end

    column :resolved_status do |duplicate|
      duplicate.resolved? ? 'Yes' : 'No'
    end
  end

  show do
    attributes_table do
      row :id
      row :good_project
      row :bad_project
      row :reporter do |d|
        d.account.name
      end
      row :comment
      row :reported_on, &:created_at
      row :resolved_status do |d|
        d.resolved? ? 'resolved' : 'unresolved'
      end
    end
  end
end
