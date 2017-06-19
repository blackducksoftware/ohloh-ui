class AddBlankTable < ActiveRecord::Migration
  def change
    create_table :foo_bar_baz do |t|
      t.string :name
    end
  end
end
