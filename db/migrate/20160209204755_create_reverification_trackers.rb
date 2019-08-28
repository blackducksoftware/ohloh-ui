# frozen_string_literal: true

class CreateReverificationTrackers < ActiveRecord::Migration
  def change
    create_table :reverification_trackers do |t|
      t.integer :account_id, null: false
      t.string :message_id, null: false
      t.integer :phase, default: 0
      t.integer :status, default: 0
      t.string :feedback
      t.integer :attempts, default: 1
      t.datetime :sent_at
      t.timestamps null: false
    end
  end
end
