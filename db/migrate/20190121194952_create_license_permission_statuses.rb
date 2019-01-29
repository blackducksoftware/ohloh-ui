class CreateLicensePermissionStatuses < ActiveRecord::Migration
  def up
    create_table :license_permission_statuses do |t|
      t.references :license_permission
      t.integer :status
      t.text :description
      t.timestamps null: false
    end
    insert_status_records

    remove_column :license_permissions, :description
  end

  def down
    add_column :license_permissions, :description, :string
    drop_table :license_permission_statuses
  end

  private

  def insert_status_records
    permission_hash = { 0 => 'PERMITTED', 1 => 'FORBIDDEN', 2 => 'RESTRICTED' }
    permission_hash.each do |key, value|
      sql = "INSERT INTO license_permission_statuses
      (license_permission_id, description, status, created_at, updated_at)
      SELECT id, '#{value} ' || description, #{key}, current_timestamp, current_timestamp
        from license_permissions"
      ActiveRecord::Base.connection.execute sql
    end
  end
end
