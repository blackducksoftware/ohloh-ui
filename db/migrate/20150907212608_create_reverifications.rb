class CreateReverifications < ActiveRecord::Migration
  def change
    create_table :reverifications do |t|
      t.belongs_to :account
      t.datetime :twitter_reverification_sent_at
      t.boolean :twitter_reverified
    end
  end
end
