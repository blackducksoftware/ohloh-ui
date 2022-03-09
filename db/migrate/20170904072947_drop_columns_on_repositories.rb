# frozen_string_literal: true

class DropColumnsOnRepositories < ActiveRecord::Migration[4.2]
  def up
    remove_column :repositories, :branch_name, :text
    remove_column :repositories, :module_name, :text
  end

  def down
    add_column :repositories, :branch_name, :text
    add_column :repositories, :module_name, :text
  end
end
