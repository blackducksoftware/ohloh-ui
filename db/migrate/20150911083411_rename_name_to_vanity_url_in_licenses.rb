# frozen_string_literal: true

class RenameNameToVanityUrlInLicenses < ActiveRecord::Migration[4.2]
  def change
    rename_column :licenses, :name, :vanity_url
  end
end
