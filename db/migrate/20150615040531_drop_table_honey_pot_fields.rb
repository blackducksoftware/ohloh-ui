# frozen_string_literal: true

class DropTableHoneyPotFields < ActiveRecord::Migration
  def change
    drop_table :honey_pot_fields
  end
end
