class AddNotificationCounterToReverifications < ActiveRecord::Migration
  def change
    add_column :reverifications, :notification_counter, :integer, default: 0
  end
end
