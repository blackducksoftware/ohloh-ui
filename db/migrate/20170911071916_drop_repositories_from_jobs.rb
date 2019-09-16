# frozen_string_literal: true

class DropRepositoriesFromJobs < ActiveRecord::Migration
  def up
    remove_foreign_key :jobs, column: :repository_id
    remove_column :jobs, :repository_id, :integer
  end

  def down
    add_column :jobs, :repository_id, :integer
    add_foreign_key :jobs, :repositories, column: :repository_id, name: :jobs_repository_id_fkey, on_delete: :cascade
  end
end
