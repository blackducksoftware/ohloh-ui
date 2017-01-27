class RenameCodeLocationEventsToFisbotEvents < ActiveRecord::Migration
  def change
    if table_exists? :code_location_events
      rename_table :code_location_events, :fisbot_events
    end
  end
end
