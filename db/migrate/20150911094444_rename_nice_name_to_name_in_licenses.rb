class RenameNiceNameToNameInLicenses < ActiveRecord::Migration
  def change
    rename_column :licenses, :nice_name, :name
  end
end
