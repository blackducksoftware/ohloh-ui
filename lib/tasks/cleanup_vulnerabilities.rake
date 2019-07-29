desc 'Cleanup old unused vulnerabilities data'
task cleanup_vulnerabilities: :environment do
  @conn = ActiveRecord::Base.connection
  Project.where.not(best_project_security_set_id: nil).select(:id, :best_project_security_set_id).find_each do |project|
    begin
      pss_ids = ProjectSecuritySet.where(project_id: project.id)
                                  .where('id < ?', project.best_project_security_set_id).select(:id).pluck(:id)
      pss_ids.each do |pss_id|
        cleanup_project_security_set(pss_id)
      end
    rescue StandardError => e
      Rails.logger.info(e.message)
    end
  end
end

def cleanup_project_security_set(project_security_set_id)
  release_ids = unused_release_ids(project_security_set_id)
  vulnerability_ids = unused_vulnerability_ids(release_ids)
  @conn.execute("DELETE FROM vulnerabilities WHERE id IN (#{vulnerability_ids.uniq.join(',')});")
  @conn.execute("DELETE FROM releases_vulnerabilities WHERE release_id IN (#{release_ids.join(',')});")
  @conn.execute("DELETE FROM releases WHERE id IN (#{release_ids.join(',')});")
  @conn.execute("DELETE FROM project_security_sets WHERE id = #{project_security_set_id};")
end

def unused_release_ids(project_security_set_id)
  release_ids = Release.where(project_security_set_id: project_security_set_id).select(:id).pluck(:id)
  release_ids = ['null'] if release_ids.blank?
  release_ids
end

def unused_vulnerability_ids(release_ids)
  vulnerability_ids = ReleasesVulnerability.where(release_id: release_ids)
                                           .select(:vulnerability_id).pluck(:vulnerability_id)
  vulnerability_ids = ['null'] if vulnerability_ids.blank?
  vulnerability_ids
end
