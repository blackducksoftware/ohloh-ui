class AddTwitterIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :twitter_id, :string
  end
end
