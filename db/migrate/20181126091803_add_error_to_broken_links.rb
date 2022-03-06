# frozen_string_literal: true

class AddErrorToBrokenLinks < ActiveRecord::Migration[4.2]
  def change
    add_column :broken_links, :error, :text
  end
end
