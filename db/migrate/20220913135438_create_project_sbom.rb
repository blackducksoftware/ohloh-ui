# frozen_string_literal: true

class CreateProjectSbom < ActiveRecord::Migration[5.2]
  def change
    create_table :project_sboms do |t|
      t.integer :project_id
      t.integer :code_location_id
      t.jsonb :sbom_data
    end
    add_index :project_sboms, :sbom_data, using: :gin
  end
end
