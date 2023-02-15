class AddColumnsToCodeLocationScan < ActiveRecord::Migration[5.2]
  def change
    add_column :code_location_scan, :language, :string
    add_column :code_location_scan, :command_line, :string
    add_column :code_location_scan, :project_token, :string
  end
end
