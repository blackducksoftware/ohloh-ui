ActiveAdmin.register FetchJob do
  belongs_to :project, :finder => :find_by_url_name!, :optional => true
  belongs_to :repository, :optional => true
  menu false
end
