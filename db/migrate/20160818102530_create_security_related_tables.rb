# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
class CreateSecurityRelatedTables < ActiveRecord::Migration
  def change
    create_table :project_security_sets do |t|
      t.references :project, index: true, foreign_key: true
      t.string :uuid, null: false
      t.string :etag
      t.timestamps
    end

    create_table :releases do |t|
      t.string :release_id, null: false, index: true
      t.datetime :released_on
      t.string :version
      t.references :project_security_set, index: true, foreign_key: true
      t.timestamps
    end

    create_table :vulnerabilities do |t|
      t.string :cve_id, null: false, index: true
      t.references :release, index: true, foreign_key: true
      t.datetime :generated_on
      t.datetime :published_on
      t.integer :severity
      t.decimal :score
      t.timestamps
    end

    add_column :projects, :best_project_security_set_id, :integer
    add_foreign_key :projects, :project_security_sets, column: :best_project_security_set_id
  end
end
# rubocop:enable Metrics/AbcSize
