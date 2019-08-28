# frozen_string_literal: true

class RemoveFiftyThousandBatchAccount < ActiveRecord::Migration
  def change
    drop_table :fifty_thousand_batch_pilot_accounts
  end
end
