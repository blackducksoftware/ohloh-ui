# frozen_string_literal: true

class CreateVerifications < ActiveRecord::Migration[4.2]
  def change
    create_table :verifications do |t|
      t.integer :account_id
      t.string :type
      t.string :auth_id

      t.timestamps null: false
    end
  end
end
