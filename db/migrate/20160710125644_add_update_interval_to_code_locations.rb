class AddUpdateIntervalToCodeLocations < ActiveRecord::Migration
  def change
    add_column :code_locations, :update_interval, :integer, default: 3600
  end
end
