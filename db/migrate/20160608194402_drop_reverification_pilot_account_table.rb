# frozen_string_literal: true

class DropReverificationPilotAccountTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :reverification_pilot_accounts
  end
end
