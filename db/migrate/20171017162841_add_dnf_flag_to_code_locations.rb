# frozen_string_literal: true

class AddDnfFlagToCodeLocations < ActiveRecord::Migration
  def change
    add_column :code_locations, :do_not_fetch, :boolean, default: false
  end
end
