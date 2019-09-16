# frozen_string_literal: true

class AddTwitterIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :twitter_id, :string
  end
end
