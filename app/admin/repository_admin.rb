ActiveAdmin.register Repository do
  actions :show, :index

  filter :url
  filter :type, as: :select
  filter :created_at
  filter :updated_at
end
