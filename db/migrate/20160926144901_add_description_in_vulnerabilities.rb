class AddDescriptionInVulnerabilities < ActiveRecord::Migration
  def change
    add_column :vulnerabilities, :description, :text
  end
end
