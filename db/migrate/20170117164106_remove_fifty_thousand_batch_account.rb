# frozen_string_literal: true

class RemoveFiftyThousandBatchAccount < ActiveRecord::Migration[4.2]
  def change
    drop_table :fifty_thousand_batch_pilot_accounts
  end
end
