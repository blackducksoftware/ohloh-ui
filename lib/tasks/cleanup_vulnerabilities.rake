desc 'Cleanup old unused vulnerabilities data'
task cleanup_vulnerabilities: :environment do
  @conn = ActiveRecord::Base.connection
  i = 1
  ProjectSecuritySet.select('distinct project_security_sets.id')
                    .joins('left join jobs on jobs.project_id = project_security_sets.project_id')
                    .joins('left join projects on projects.best_project_security_set_id = project_security_sets.id')
                    .where(projects: { best_project_security_set_id: nil })
                    .where("(jobs.type = 'VulnerabilityJob' and status in (3,5)) or jobs.type is null")
                    .find_in_batches(batch_size: 10_000) do |pss_ids|
    begin
      pss_ids = pss_ids.map(&:id)
      release_ids = Release.where(project_security_set_id: pss_ids).ids
      vulnerability_ids = ReleasesVulnerability.where(release_id: release_ids).pluck(:vulnerability_id)
      if vulnerability_ids.present?
        @conn.execute("DELETE FROM vulnerabilities WHERE id IN (#{vulnerability_ids.uniq.join(',')});")
      end
      if release_ids.present?
        @conn.execute("DELETE FROM releases_vulnerabilities WHERE release_id IN (#{release_ids.join(',')});")
        @conn.execute("DELETE FROM releases WHERE id IN (#{release_ids.join(',')});")
      end
      @conn.execute("DELETE FROM project_security_sets WHERE id IN (#{pss_ids.join(',')});")
      puts "Iteration ##{i} completed."
      i += 1
    rescue StandardError => e
      Rails.logger.info(e.message)
    end
  end
end
