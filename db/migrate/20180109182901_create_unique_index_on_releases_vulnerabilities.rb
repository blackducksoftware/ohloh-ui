class CreateUniqueIndexOnReleasesVulnerabilities < ActiveRecord::Migration
  def change
    index_exist = index_exists?(:releases_vulnerabilities, [:release_id, :vulnerability_id],
                                unique: true, name: 'releases_vulnerabilities_release_id_vulnerability_id_idx')
    return if index_exist
    add_index :releases_vulnerabilities, [:release_id, :vulnerability_id],
              unique: true, name: 'releases_vulnerabilities_release_id_vulnerability_id_idx'
  end
end
