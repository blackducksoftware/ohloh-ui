# frozen_string_literal: true

class CreateProjectSbom < ActiveRecord::Migration[5.2]
  def change
    create_table :project_sboms do |t|
      t.integer :project_id
      t.integer :code_location_id
      t.json :sbom_data
    end
  end
end
