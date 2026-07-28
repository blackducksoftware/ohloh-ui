# frozen_string_literal: true

class AddJwtLockoutColumnsToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :jwt_failed_attempts, :integer, default: 0
    add_column :accounts, :jwt_failed_attempts_window_start, :datetime
    add_column :accounts, :jwt_locked_until, :datetime
  end
end
