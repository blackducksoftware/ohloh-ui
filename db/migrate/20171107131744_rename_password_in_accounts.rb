# frozen_string_literal: true

class RenamePasswordInAccounts < ActiveRecord::Migration[4.2]
  def change
    change_table :accounts, bulk: true do |t|
      t.rename :crypted_password, :encrypted_password
      t.change :encrypted_password, :string

      t.rename :reset_password_tokens, :confirmation_token
      t.change :confirmation_token, :string

      Account.connection.execute('update accounts set remember_token = md5(random()::text);')
      t.change :remember_token, :string, limit: 128, null: false
      add_index :accounts, :remember_token
    end
  end
end
