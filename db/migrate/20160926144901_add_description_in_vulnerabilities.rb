# frozen_string_literal: true

class AddDescriptionInVulnerabilities < ActiveRecord::Migration
  def change
    add_column :vulnerabilities, :description, :text
  end
end
