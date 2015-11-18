class RenameUrlNameToVanityUrlInProjects < ActiveRecord::Migration
  def change
    rename_column :projects, :url_name, :vanity_url
  end
end
