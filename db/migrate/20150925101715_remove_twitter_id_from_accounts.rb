# frozen_string_literal: true

class RemoveTwitterIdFromAccounts < ActiveRecord::Migration[4.2]
  def change
    remove_column :accounts, :twitter_id, :string
  end
end
