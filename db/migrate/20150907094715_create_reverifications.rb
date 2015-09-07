class CreateReverifications < ActiveRecord::Migration
  def change
    create_table :reverifications do |t|
      t.integer :account_id
      t.datetime :sent_at
    end
  end
end
