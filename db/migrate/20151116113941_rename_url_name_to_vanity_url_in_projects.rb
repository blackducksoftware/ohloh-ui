# frozen_string_literal: true

class RenameUrlNameToVanityUrlInProjects < ActiveRecord::Migration[4.2]
  def change
    rename_column :projects, :url_name, :vanity_url
  end
end
