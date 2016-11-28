class DropReverificationPilotAccountTable < ActiveRecord::Migration
  def change
    drop_table :reverification_pilot_accounts
  end
end
