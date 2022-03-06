# frozen_string_literal: true

class AddTwitterIdToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :twitter_id, :string
  end
end
