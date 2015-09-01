ActiveAdmin.register Job do
  permit_params :status, :priority, :wait_until, :current_step_at, :notes
  menu false


end
