# frozen_string_literal: true

class RemoveUnusedTables < ActiveRecord::Migration
  def up
    remove_foreign_key :old_edits, :project
    remove_foreign_key :old_edits, :account
    remove_foreign_key :old_edits, column: :undone_by

    remove_foreign_key :koders_statuses, :project

    remove_foreign_key :project_gestalts, :gestalt
    remove_foreign_key :project_gestalts, :project

    remove_foreign_key :code_set_gestalts, :code_set
    remove_foreign_key :code_set_gestalts, :gestalt

    execute <<-SQL
      DROP VIEW project_gestalt_view;
    SQL
    drop_table :code_set_gestalts
    drop_table :project_gestalts
    drop_table :koders_statuses
    drop_table :gestalts
    drop_table :old_edits
  end

  # rubocop:disable Metrics/AbcSize
  def down
    create_table :old_edits do |t|
      t.references :project, foreign_key: true
      t.references :account, foreign_key: true
      t.text :type
      t.text :key
      t.text :value
      t.boolean :undone
      t.timestamp :undone_at
      t.timestamp :created_at
      t.integer :undone_by
    end
    add_foreign_key :old_edits, :accounts, column: :undone_by

    create_table :koders_statuses do |t|
      t.references :project, foreign_key: true, null: false, index: { unique: true }
      t.integer :koders_id, index: { unique: true }
      t.integer :flags, null: false, default: 0
      t.timestamp :ohloh_updated_at
      t.timestamp :koders_updated_at
      t.text :error
      t.boolean :ohloh_code_ready, default: false
    end

    create_table :gestalts do |t|
      t.text :type, null: false
      t.text :name, null: false, index: true
      t.text :description
    end

    create_table :project_gestalts do |t|
      t.timestamp :date, null: false
      t.references :project, foreign_key: true, index: true
      t.references :gestalt, foreign_key: true, index: true
    end

    create_table :code_set_gestalts do |t|
      t.timestamp :date, null: false
      t.references :code_set, foreign_key: true, index: true
      t.references :gestalt, foreign_key: true, index: true
    end

    execute <<-SQL
      CREATE VIEW project_gestalt_view as SELECT p.id AS project_id, p.vanity_url AS url_name,
      g.id AS gestalt_id, g.name, g.type FROM projects p
      JOIN project_gestalts pg ON p.id = pg.project_id
      JOIN gestalts g ON g.id = pg.gestalt_id;
    SQL
  end
  # rubocop:enable Metrics/AbcSize
end
