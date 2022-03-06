# frozen_string_literal: true

class RemoveTiesBetweenRepositoryAndCodeSet < ActiveRecord::Migration[4.2]
  def up
    remove_foreign_key :repositories, column: :best_code_set_id
    remove_index :repositories, :best_code_set_id
    remove_column :repositories, :best_code_set_id

    remove_foreign_key :code_sets, column: :repository_id
    remove_index :code_sets, :repository_id
    remove_column :code_sets, :repository_id
  end

  def down
    add_column :repositories, :best_code_set_id, :integer
    add_index :repositories, :best_code_set_id
    add_foreign_key :repositories, :code_sets, column: :best_code_set_id, name: :repositories_best_code_set_id_fkey

    add_column :code_sets, :repository_id, :integer
    add_index :code_sets, :repository_id
    add_foreign_key :code_sets, :code_sets, column: :repository_id, name: :code_sets_repository_id_fkey
  end
end
