ActiveAdmin.register RegistrationKey do
  permit_params :client_name, :description
  filter :id_equals
  filter :client_name
end
