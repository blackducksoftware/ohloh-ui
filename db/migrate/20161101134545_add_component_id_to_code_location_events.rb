# frozen_string_literal: true

class AddComponentIdToCodeLocationEvents < ActiveRecord::Migration
  def change
    add_column :code_location_events, :component_id, :integer
  end
end
