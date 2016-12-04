class CreateFiftyThousandBatchPilotAccount < ActiveRecord::Migration
  def change
    create_table :fifty_thousand_batch_pilot_accounts do |t|
      t.integer :account_id, null: false
      t.timestamps null: false
    end
  end
end
