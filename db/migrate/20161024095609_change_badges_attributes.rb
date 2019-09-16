# frozen_string_literal: true

class ChangeBadgesAttributes < ActiveRecord::Migration
  def self.up
    remove_column :project_badges, :deleted
    add_column :project_badges, :status, :integer, default: 1
    rename_column :project_badges, :url, :identifier
  end

  def self.down
    add_column :project_badges, :deleted, :boolean, default: false
    remove_column :project_badges, :status
    rename_column :project_badges, :identifier, :url
  end
end
