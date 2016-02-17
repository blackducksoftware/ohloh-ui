class AddUuiDtoProject < ActiveRecord::Migration
  def change
    add_column :projects, :uuid, :string
  end
end
