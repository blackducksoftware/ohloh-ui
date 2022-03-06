# frozen_string_literal: true

class CreateRepositoryDirectoriesTable < ActiveRecord::Migration[4.2]
  def change
    create_table :repository_directories do |t|
      t.references :code_location, foreign_key: true, index: true
      t.references :repository, foreign_key: true, index: true
      t.timestamp :fetched_at
    end

    add_column :code_locations, :best_repository_directory_id, :integer, index: true
    add_column :repositories, :best_repository_directory_id, :integer, index: true
  end
end
