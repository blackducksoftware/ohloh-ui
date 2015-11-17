ActiveAdmin.register SlocJob do
  belongs_to :project, finder: :find_by_url_name!, optional: true
  actions :index, :show, :destroy, :edit
  menu false
end
