class RemoveCodelocationStatusDefault < ActiveRecord::Migration
  def self.up
    change_column_default :code_locations, :status, nil
  end

  def self.down
    change_column_default :code_locations, :status, 1
  end
end
