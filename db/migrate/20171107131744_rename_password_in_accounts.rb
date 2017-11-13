class RenamePasswordInAccounts < ActiveRecord::Migration
  def change
    change_table :accounts, bulk: true do |t|
      t.rename :crypted_password, :encrypted_password
      t.change :encrypted_password, :string

      t.rename :reset_password_tokens, :confirmation_token
      t.change :confirmation_token, :string
    end
  end
end
