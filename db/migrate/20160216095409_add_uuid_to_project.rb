# frozen_string_literal: true

class AddUuidToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :uuid, :string
  end
end
