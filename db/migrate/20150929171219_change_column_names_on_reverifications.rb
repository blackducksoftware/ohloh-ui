class ChangeColumnNamesOnReverifications < ActiveRecord::Migration
  def change
    rename_column :reverifications, :twitter_reverified, :verified
    rename_column :reverifications, :twitter_reverification_sent_at, :initial_email_sent_at
    change_column_default :reverifications, :verified, false
  end
end
