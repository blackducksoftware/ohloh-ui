class AddAccountReferencetoReverifications < ActiveRecord::Migration
  def change
    remove_column :reverifications, :account_id
    add_reference :reverifications, :account
  end
end
