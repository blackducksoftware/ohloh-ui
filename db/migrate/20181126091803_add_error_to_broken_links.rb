# frozen_string_literal: true

class AddErrorToBrokenLinks < ActiveRecord::Migration
  def change
    add_column :broken_links, :error, :text
  end
end
