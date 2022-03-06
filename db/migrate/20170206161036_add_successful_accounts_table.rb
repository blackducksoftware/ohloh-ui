# frozen_string_literal: true

class AddSuccessfulAccountsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :successful_accounts do |t|
      t.integer :account_id
    end
  end
end
