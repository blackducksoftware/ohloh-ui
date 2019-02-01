class CreateLicensePermissionTables < ActiveRecord::Migration
  def up
    rename_table :license_permissions, :license_rights

    create_table :license_permissions do |t|
      t.references :license_right
      t.integer :status
      t.text :description
      t.timestamps null: false
    end

    create_table :license_license_permissions do |t|
      t.references :license
      t.references :license_permission
      t.timestamps null: false
    end

    insert_permission_records
    insert_license_license_permission_records

    # this should be done for production
    remove_column :license_rights, :description
  end

  def down
    drop_table :license_license_permissions
    drop_table :license_permissions
    rename_table :license_rights, :license_permissions
    add_column :license_permissions, :description, :string
  end

  private

  def insert_permission_records
    permission_hash = { 0 => 'PERMITTED', 1 => 'FORBIDDEN', 2 => 'RESTRICTED' }
    permission_hash.each do |key, value|
      sql = "INSERT INTO license_permissions
      (license_right_id, description, status, created_at, updated_at)
      SELECT id, '#{value} ' || description, #{key}, current_timestamp, current_timestamp
        FROM license_rights;"
      ActiveRecord::Base.connection.execute sql
    end
  end

  def insert_license_license_permission_records
    sql = "INSERT INTO license_license_permissions
    (license_id, license_permission_id, created_at, updated_at)
    SELECT lpr.license_id, lp.id, current_timestamp, current_timestamp
      FROM license_permissions lp
      INNER JOIN license_permission_roles lpr
        ON license_permission_id = lp.license_right_id
      AND lpr.status = lp.status ;"
    ActiveRecord::Base.connection.execute sql
  end
end
