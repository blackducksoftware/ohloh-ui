class AddUuidtoProject < ActiveRecord::Migration
  def change
    add_column :projects, :uuid, :string
  end
end
