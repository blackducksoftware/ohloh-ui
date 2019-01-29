class DropLicensePermissionRolesStatus < ActiveRecord::Migration
  def up
    add_column :license_permission_roles, :license_permission_status_id, :integer

    update_status_id

    remove_columns :license_permission_roles, :status, :license_permission_id
  end

  def down
    add_column :license_permission_roles, :status, :integer
    add_column :license_permission_roles, :license_permission_id, :integer
    remove_column :license_permission_roles, :license_permission_status_id
  end

  private

  def update_status_id
    sql = 'UPDATE license_permission_roles
    SET license_permission_status_id = q.lps_id
    FROM
    (select lps.id as lps_id, license_permission_id, status, name, icon
      from license_permission_statuses lps
      inner join license_permissions lp on lps.license_permission_id = lp.id) as q
    WHERE license_permission_roles.license_permission_id = q.license_permission_id
    AND license_permission_roles.status = q.status ;'

    ActiveRecord::Base.connection.execute sql
  end
end
