ActiveAdmin.register LicensePermissionRole do
  permit_params :status, :license_id, :license_permission_id

  # filter :license, collection: proc { License.active.order(:name) }
  # filter :license_permission, collection: proc { LicensePermission.order(:name) }
  filter :status

  index do
    column :id
    column 'License' do |license|
      License.find(license.license_id).name
    end
    column 'License Permission' do |permission|
      LicensePermission.find(permission.license_permission_id).name
    end
    # column :status
    actions
  end

  form do |f|
    f.inputs 'License Permiission Role' do
      f.input :license, as: :select, collection: License.order(:name)
      f.input :license_permission, as: :select
      f.input :status
      actions
    end
  end

  action_item :add_another_new, only: :show do
    link_to 'Add another License Permission role', new_admin_license_permission_role_path
  end
end
