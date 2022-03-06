# frozen_string_literal: true

class CreateCodeLocationTarballsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :code_location_tarballs do |t|
      t.references :code_location, foreign_key: true, index: true
      t.text :commit_sha1, index: true
      t.text :filepath
      t.integer :status, default: 0
      t.timestamp :created_at
    end

    add_column :jobs, :code_location_tarball_id, :integer, index: true
  end
end
