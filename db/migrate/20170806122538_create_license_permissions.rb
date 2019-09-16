# frozen_string_literal: true

class CreateLicensePermissions < ActiveRecord::Migration
  def change
    create_table :license_permissions do |t|
      t.string :name
      t.string :description
      t.string :icon

      t.timestamps null: false
    end
  end
end
