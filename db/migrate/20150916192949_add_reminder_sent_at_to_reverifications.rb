class AddReminderSentAtToReverifications < ActiveRecord::Migration
  def change
    add_column :reverifications, :reminder_sent_at, :datetime
  end
end
