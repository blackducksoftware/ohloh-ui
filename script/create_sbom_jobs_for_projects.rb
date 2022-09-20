# frozen_string_literal: true

# ruby script/create_sbom_jobs_for_projects.rb <project_limit>

require_relative '../config/environment'

module CreateSbomJobs
  module_function

  PRIORITY = 0

  def perform(limit)
    projects = projects_without_sboms(limit)

    projects.each do |project|
      project.enlistments.not_deleted.each do |enlistment|
        code_location_id = enlistment.code_location_id
        code_set = find_or_create_recent_code_set(code_location_id)

        SbomJob.create!(code_set_id: code_set.id, code_location_id: code_location_id,
                        project_id: project.id, priority: PRIORITY)
      end

      puts "Created SbomJobs for the project => #{project.id}: #{project.vanity_url}"
    end
  end

  def projects_without_sboms(limit)
    Project.active.joins(:enlistments)
           .joins('JOIN code_locations cl ON cl.id = enlistments.code_location_id
                   JOIN repositories ON repositories.id = cl.repository_id')
           .where("repositories.type = 'GitRepository' AND
                   NOT EXISTS(SELECT 1 FROM project_sboms WHERE project_id = projects.id) AND
                   NOT EXISTS(SELECT 1 FROM jobs WHERE type = 'SbomJob' and project_id = projects.id)")
           .limit(limit)
  end

  def find_or_create_recent_code_set(code_location_id)
    CodeSet.where(code_location_id: code_location_id).last ||
      CodeSet.create!(code_location_id: code_location_id)
  end
end

CreateSbomJobs.perform(ARGV[0])
