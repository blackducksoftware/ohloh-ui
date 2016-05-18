class AddCodeLocationTable < ActiveRecord::Migration
  def up
    create_table :code_locations do |t|
      t.references :repository, index: true, foreign_key: true
      t.text :module_branch_name, null: false
      t.integer :status, default: 1
      t.timestamps
    end

    add_column :enlistments, :code_location_id, :integer
    add_index :enlistments, :code_location_id

    #remove_column :enlistments, :repository_id
    #remove_column :repositories, :module_name
    #remove_column :repositories, :branch_name

    execute <<-SQL
      ALTER TABLE code_locations ADD CONSTRAINT code_locations_unique_repository_id_module_branch_name
        UNIQUE(repository_id, module_branch_name)
    SQL

    execute <<-SQL
      ALTER TABLE enlistments DROP CONSTRAINT unique_project_id_repository_id
    SQL
  end

  def down
    remove_column :enlistments, :code_location_id
    execute <<-SQL
      ALTER TABLE enlistments ADD CONSTRAINT unique_project_id_repository_id
        UNIQUE(project_id, repository_id)
    SQL
    drop_table :code_locations
  end
end
