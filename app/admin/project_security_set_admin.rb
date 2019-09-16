# frozen_string_literal: true

ActiveAdmin.register ProjectSecuritySet do
  filter :project_name_eq, label: 'project_name'
  filter :project_vanity_url_eq, label: 'project_vanity_url'
  filter :uuid

  actions :index, :show

  index do
    column :id
    column :project_name do |obj|
      obj.project.name
    end
    column :project_vanity_url do |obj|
      link_to obj.project.vanity_url, project_path(obj.project)
    end
    column :uuid
    column :etag
    actions do |obj|
      link_to 'releases', admin_project_security_set_releases_path(obj)
    end
  end
end
