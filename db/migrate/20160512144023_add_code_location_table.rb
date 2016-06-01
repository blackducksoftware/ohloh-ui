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

    add_column :enlistments, :code_location_id, :integer
    add_column :jobs, :code_location_id, :integer
    add_column :code_sets, :code_location_id, :integer

    change_column_null :enlistments, :repository_id, true
    change_column_null :code_sets, :repository_id, true

    add_index :enlistments, :code_location_id
    add_index :jobs, :code_location_id
    add_index :code_sets, :code_location_id

    # remove_column :enlistments, :repository_id

    # remove_column :repositories, :module_name
    # remove_column :repositories, :branch_name
    # remove_column :repositories, :best_code_set_id

    # remove_column :jobs, :repository_id
    # remove_column :code_sets, :code_location_id

    execute <<-SQL
      ALTER TABLE code_locations ADD CONSTRAINT code_locations_unique_repository_id_module_branch_name
        UNIQUE(repository_id, module_branch_name);
      ALTER TABLE code_locations ADD FOREIGN KEY(best_code_set_id) REFERENCES code_sets(id);
    SQL

    execute <<-SQL
      ALTER TABLE enlistments DROP CONSTRAINT unique_project_id_repository_id;
      ALTER TABLE enlistments ADD CONSTRAINT unique_project_id_code_location_id
        UNIQUE(project_id, code_location_id);
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
