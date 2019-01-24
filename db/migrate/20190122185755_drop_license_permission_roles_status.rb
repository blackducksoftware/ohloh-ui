class DropLicensePermissionRolesStatus < ActiveRecord::Migration
  def up
    add_column :license_permission_roles, :license_permission_status_id, :integer

    update_status_id

    remove_columns :license_permission_roles, :status, :license_permission_id
  end

  def down
    add_column :license_permission_roles, :status, :integer
    remove_column :license_permission_roles, :license_permission_status_id
  end

  private

  def update_status_id
    sql = 'UPDATE license_permission_roles
    SET license_permission_status_id = q.lps_id
    FROM
    (SELECT lpr.id, lps.id as lps_id 
      FROM license_permission_statuses lps
      INNER JOIN license_permission_roles lpr ON lpr.status = lps.status
      ORDER BY lpr.status) AS q
    WHERE license_permission_roles.id = q.id'

    ActiveRecord::Base.connection.execute sql
  end
end
