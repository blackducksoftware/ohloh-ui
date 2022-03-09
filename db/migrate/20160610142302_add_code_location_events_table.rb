# frozen_string_literal: true

class AddCodeLocationEventsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :code_location_events do |t|
      t.references :code_location, index: true, foreign_key: true
      t.text :type, null: false
      t.text :value
      t.text :commit_sha1
      t.boolean :status
      t.timestamps null: false
    end
  end
end
