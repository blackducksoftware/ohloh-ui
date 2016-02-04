class CreateAccountReverifications < ActiveRecord::Migration
  def change
    create_table :account_reverifications do |t|
      t.integer :account_id
      t.string :status, default: 'initial'
      t.timestamps null: false
    end
  end
end
