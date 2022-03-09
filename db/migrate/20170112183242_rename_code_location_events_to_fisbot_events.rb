# frozen_string_literal: true

class RenameCodeLocationEventsToFisbotEvents < ActiveRecord::Migration[4.2]
  def change
    rename_table :code_location_events, :fisbot_events
  end
end
