# frozen_string_literal: true

class DropTableHoneyPotFields < ActiveRecord::Migration[4.2]
  def change
    drop_table :honey_pot_fields
  end
end
