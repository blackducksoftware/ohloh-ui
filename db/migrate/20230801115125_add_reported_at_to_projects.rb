# frozen_string_literal: true

class AddReportedAtToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :reported_at, :datetime
  end
end
