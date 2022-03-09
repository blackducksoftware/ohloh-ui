# frozen_string_literal: true

class AddComponentIdToCodeLocationEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :code_location_events, :component_id, :integer
  end
end
