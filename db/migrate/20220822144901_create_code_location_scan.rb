# frozen_string_literal: true

class CreateCodeLocationScan < ActiveRecord::Migration[5.2]
  def change
    create_table :code_location_scan do |t|
      t.integer :code_location_id
      t.integer :scan_project_id
    end
  end
end
