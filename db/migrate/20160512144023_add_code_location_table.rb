# rubocop: disable Metrics/AbcSize

class AddCodeLocationTable < ActiveRecord::Migration
  def up
    create_table :code_locations do |t|
      t.references :repository, index: true, foreign_key: true
      t.text :module_branch_name
      t.integer :status, default: 1
      t.integer :best_code_set_id, index: true
      t.timestamps
    end

    add_foreign_key :code_locations, :code_sets, column: :best_code_set_id

    add_column :enlistments, :code_location_id, :integer
    add_column :jobs, :code_location_id, :integer
    add_column :code_sets, :code_location_id, :integer

    change_column_null :enlistments, :repository_id, true
    change_column_null :code_sets, :repository_id, true

    add_index :enlistments, :code_location_id
    add_index :enlistments, %i[project_id code_location_id], unique: true
    add_index :jobs, :code_location_id
    add_index :code_sets, :code_location_id
    add_index :code_locations, %i[repository_id module_branch_name], unique: true

    execute <<-SQL
      ALTER TABLE enlistments DROP CONSTRAINT unique_project_id_repository_id;
    SQL
  end

  def down
    remove_column :enlistments, :code_location_id
    remove_column :jobs, :code_location_id
    remove_column :code_sets, :code_location_id

    change_column_null :enlistments, :repository_id, false
    change_column_null :code_sets, :repository_id, false

    execute <<-SQL
      ALTER TABLE enlistments ADD CONSTRAINT unique_project_id_repository_id
        UNIQUE(project_id, repository_id)
    SQL
    drop_table :code_locations
  end
end
