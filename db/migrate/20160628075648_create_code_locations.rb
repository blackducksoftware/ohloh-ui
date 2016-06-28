class CreateCodeLocations < ActiveRecord::Migration
  def change
    create_table :code_locations do |t|
      t.references :repository
      t.text :branch_name
      t.integer :status_code, default: 1

      t.timestamps null: false
    end

    add_index :code_locations, :repository_id

    add_column :repositories, :prime_code_location_id, :integer
  end
end
