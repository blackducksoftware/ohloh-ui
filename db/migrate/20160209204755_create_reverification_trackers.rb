class CreateReverificationTrackers < ActiveRecord::Migration
  def change
    create_table :reverification_trackers do |t|
      t.integer :account_id
      t.integer :status, default: 0
      t.timestamps null: false
    end
  end
end
