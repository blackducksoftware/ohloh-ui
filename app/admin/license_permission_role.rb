ActiveAdmin.register LicensePermissionRole do
  permit_params :status, :license_id, :license_permission_id

  index do
    column :id
    column :license_id
    column :license_permission_id
    column :status
    actions
  end

  form do |f|
    f.inputs 'License Permiission Role' do
      f.input :license, as: :select, collection: License.select(:name).order(:name)
      f.input :license_permission, as: :select
      f.input :status
      actions
    end
  end
end
