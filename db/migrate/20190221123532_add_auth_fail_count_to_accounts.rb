# frozen_string_literal: true

class AddAuthFailCountToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :auth_fail_count, :integer, default: 0
  end
end
