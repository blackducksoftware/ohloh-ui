# frozen_string_literal: true

class ChangeReleaseIdColumnTypeOfReleasesVulnerabilities < ActiveRecord::Migration
  def change
    change_column :releases_vulnerabilities, :release_id, :bigint
  end
end
