# frozen_string_literal: true

class RenameLoggedAt < ActiveRecord::Migration[4.2]
  def change
    rename_column :sloc_sets, :logged_at, :code_set_time
    rename_column :analysis_sloc_sets, :logged_at, :code_set_time
    rename_column :analyses, :logged_at, :oldest_code_set_time
  end
end
