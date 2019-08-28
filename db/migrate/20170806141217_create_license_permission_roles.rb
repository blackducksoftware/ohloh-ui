# frozen_string_literal: true

class CreateLicensePermissionRoles < ActiveRecord::Migration
  def change
    create_table :license_permission_roles do |t|
      t.references :license
      t.references :license_permission
      t.integer :status

      t.timestamps null: false
    end
  end
end
