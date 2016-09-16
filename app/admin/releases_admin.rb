ActiveAdmin.register Release do
  filter :release_id
  filter :version
  filter :project_security_set_id

  actions :index, :show

  index do
    column :id
    column :release_id, label: :release_id
    column :released_on
    column :version
    column :project_security_set_id
    column :vulnerabilities_count do |obj|
      link_to obj.vulnerabilities.count, admin_release_vulnerabilities_path(obj)
    end
    column :created_at
    column :updated_at
    actions
  end

  controller do
    def scoped_collection
      ProjectSecuritySet.find(params[:project_security_set_id]).releases
    end
  end
end
