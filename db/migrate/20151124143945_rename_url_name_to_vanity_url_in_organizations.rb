# frozen_string_literal: true

class RenameUrlNameToVanityUrlInOrganizations < ActiveRecord::Migration[4.2]
  def change
    rename_column :organizations, :url_name, :vanity_url
    rename_column :org_thirty_day_activities, :url_name, :vanity_url
  end
end
