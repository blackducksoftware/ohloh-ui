# frozen_string_literal: true

class RemoveConstraintsFromSecurityTables < ActiveRecord::Migration[4.2]
  def change
    remove_index :releases, column: :kb_release_id
    remove_index :vulnerabilities, column: :cve_id

    add_index :releases, :kb_release_id
    add_index :vulnerabilities, :cve_id

    add_reference :releases, :project_security_set, foreign_key: false

    drop_table :pss_release_vulnerabilities
    create_join_table :releases, :vulnerabilities
  end
end
