# frozen_string_literal: true

class AddScanProjectIdToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :coverity_project_id, :integer
  end
end
