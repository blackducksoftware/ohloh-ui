# frozen_string_literal: true

class ChangeReleaseIdColumnTypeOfReleasesVulnerabilities < ActiveRecord::Migration[4.2]
  def change
    change_column :releases_vulnerabilities, :release_id, :bigint
  end
end
