desc 'Cleanup old unused vulnerabilities data'
task cleanup_vulnerabilities: :environment do
  i = 1
  ProjectSecuritySet.select('distinct project_security_sets.id')
                    .joins('inner join jobs on jobs.project_id = project_security_sets.project_id')
                    .joins('left join projects on projects.best_project_security_set_id = project_security_sets.id')
                    .where(projects: { best_project_security_set_id: nil })
                    .where(jobs: { type: 'VulnerabilityJob', status: [3, 5] })
                    .find_in_batches(batch_size: 100) do |pss_ids|
    begin
      pss_ids = pss_ids.map(&:id)
      release_ids = Release.where(project_security_set_id: pss_ids).ids
      vulnerability_ids = ReleasesVulnerability.where(release_id: release_ids).pluck(:vulnerability_id)
      Vulnerability.where(id: vulnerability_ids.uniq).delete_all
      ReleasesVulnerability.where(release_id: release_ids).delete_all
      Release.where(id: release_ids).delete_all
      ProjectSecuritySet.where(id: pss_ids).delete_all
      puts "Iteration ##{i} completed."
      i += 1
    rescue StandardError => e
      Rails.logger.info(e.message)
    end
  end
end
