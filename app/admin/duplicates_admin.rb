ActiveAdmin.register Duplicate do
  config.filters = false
  actions :index, :show

  index do
    column :id, sortable: :id do |duplicate|
      link_to duplicate.id, duplicate_path(duplicate)
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
  end
end
