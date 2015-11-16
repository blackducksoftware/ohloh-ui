ActiveAdmin.register CompleteJob do
  menu false

  belongs_to :project, finder: :find_by_url_name!, optional: true
  belongs_to :repository, optional: true
end
