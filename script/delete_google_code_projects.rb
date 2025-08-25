#! /usr/bin/env ruby
# frozen_string_literal: true

raise 'RAILS_ENV is undefined' unless ENV['RAILS_ENV']

require_relative '../config/environment'
require 'logger'

class DeleteGoogleCodeProjects
  def initialize
    @log = Logger.new('log/deleted_googlecode_log_file.log')
    @editor = Account.find_by(login: 'ohloh_slave')
  end

  # rubocop:disable Metrics/MethodLength
  def execute
    DataDogReport.info 'starting script'
    @project_ids = fetch_googlecode_projects_array
    DataDogReport.info "Attempting to delete #{@project_ids.length} google code projects"

    # update project deleted field for all googlecode projects in batches of 1000
    until (projects = Project.find(@project_ids.slice!(0..999))).empty?
      projects.each do |project|
        undo_project(project)
      end
    end
    DataDogReport.info(
      'Successfully completed script - Please check deleted_googlecode_log_file.log to view any exceptions'
    )
  end
  # rubocop:enable Metrics/MethodLength

  def fetch_googlecode_projects_array
    ActiveRecord::Base.connection.select_values("SELECT p.id as project_id
        FROM code_locations cl inner join repositories r ON cl.repository_id = r.id
        INNER JOIN enlistments e ON e.code_location_id = cl.id
        INNER JOIN projects p ON e.project_id = p.id
        INNER JOIN (SELECT project_id
           FROM enlistments
           GROUP BY project_id
           HAVING count(*) = 1)e1 ON e1.project_id = p.id
           WHERE r.url like '%googlecode.com%' AND p.deleted = False")
  end

  def undo_project(project)
    DataDogReport.info "Processing project #{project.id}"
    begin
      project.tags.delete_all
      project.create_edit.undo!(@editor) if project.create_edit.allow_undo?
    rescue StandardError => e
      @log.error "error: #{project.id} - #{e.inspect}"
    end
  end
end

DeleteGoogleCodeProjects.new.execute
