# frozen_string_literal: true

class AddPasswordResetRateLimitToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :password_reset_count, :integer, default: 0, null: false
    add_column :accounts, :password_reset_requested_at, :datetime
  end
end
