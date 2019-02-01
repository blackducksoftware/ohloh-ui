ActiveAdmin.register LicenseLicensePermission, as: "license_permission" do
    permit_params :status, :license_id, :license_permission_id

    filter :license, collection: proc { License.active.order(:name) }
    # filter :license_permission, collection: proc { LicenseRight.order(:name) }
    # filter :status, as: :select, collection: [['Permitted', 0],
    #                                         ['Forbidden', 1],
    #                                         ['Required', 2]]

    index do
      column :id
      column 'License' do |permission|
        permission.license.name
      end
      column 'License Permission' do |permission|
        permission.name
      end
      column :status
      actions
    end

    form do |f|
      f.inputs 'License Permissions' do
        f.input :license, as: :select, collection: License.order(:name)
        f.input :license_permission, as: :select
        # f.input :status, as: :select, collection: LicensePermission.statuses.keys
        actions
      end
    end

    action_item :add_another_new, only: :show do
      link_to 'Add another License Permission', new_admin_license_permission_role_path
    end
  end
