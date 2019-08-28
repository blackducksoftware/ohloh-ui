# frozen_string_literal: true

class AddIndexOnSecurityTables < ActiveRecord::Migration
  def change
    add_index :releases, :project_security_set_id
    add_index :releases_vulnerabilities, :release_id
    add_index :releases_vulnerabilities, :vulnerability_id
  end
end
