ActiveAdmin.register CodeLocation do
  filter :branch_name
  filter :repository_url, as: :string
  filter :repository_type, as: :select, collection: proc { Repository.subclasses.map(&:name) }

  index do
    column :id do |code_location|
      link_to code_location.id, admin_code_location_path(code_location)
    end
    column :repository_type do |code_location|
      code_location.repository.type
    end
    column :repository_url do |code_location|
      code_location.repository.url
    end
    column :branch_name
    column :status do |code_location|
      code_location.status.capitalize
    end
    column :created_at
    column :repository do |code_location|
      link_to code_location.repository.id, admin_repository_path(code_location.repository)
    end
  end

  show do
    render 'admin/repositories/repository', repository: code_location.repository
  end

  sidebar 'CodeLocation Details', only: :show do
    attributes_table_for code_location do
      rows(*code_location.attribute_names)
    end
  end
end
