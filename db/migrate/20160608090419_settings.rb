# frozen_string_literal: true

class Settings < ActiveRecord::Migration[4.2]
  def change
    create_table :settings do |t|
      t.string :key
      t.string :value
      t.timestamps
    end
    add_index :settings, :key, unique: true
  end
end
