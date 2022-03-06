# frozen_string_literal: true

class RenameNiceNameToNameInLicenses < ActiveRecord::Migration[4.2]
  def change
    rename_column :licenses, :nice_name, :name
  end
end
