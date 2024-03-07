# frozen_string_literal: true

class CreateMaintenanceRoutes < ActiveRecord::Migration[5.2]
  def change
    create_table :maintenance_routes, id: false do |t|
      t.string :path
    end
  end
end
