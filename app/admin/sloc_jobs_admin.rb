ActiveAdmin.register SlocJob do
  belongs_to :project, :finder => :find_by_url_name!, :optional => true
  menu false
end
