# frozen_string_literal: true

class CreateBrokenLinks < ActiveRecord::Migration[4.2]
  def change
    create_table :broken_links do |t|
      t.references :link, foreign_key: true
      t.timestamps
    end
  end
end
