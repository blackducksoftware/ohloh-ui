#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

class CreateScanProjectInUi
  include JWTHelper

  def initialize
    @filename = 'vendor/active_projects.csv'
    @jwt = build_jwt(Account.hamster.login)
    @headers = %w[name repo_url]
  end

  def execute
    CSV.foreach(@filename, headers: true) do |row|
      existing_project = Project.find_by_name(row['name'])
      params = { JWT: @jwt, name: row['name'], repo_url: fix_url(row['repo_url']), license_name: row['license_name'],
                 coverity_project_id: row['id'] }
      project = create_scan_project(params) if existing_project.nil?

      next if project.nil?

      puts "Project Value #{project} row value #{row['name']}"
      insert_failed_url_data(project, row)
      create_code_location_scan(project, row) if project.is_a? Numeric
    end
  end

  private

  def create_scan_project(params)
    uri = URI("#{ENV['URL_HOST']}/api/v1/projects.json")
    response = Net::HTTP.post_form(uri, params)
    JSON.parse(response.body)
  rescue StandardError => e
    puts e.message
  end

  def fix_url(url)
    new_url = url.strip.chomp('/')
    return new_url unless url.match('github.com')

    new_url.sub(/\.git$/, '')
           .sub(%r{^git://}, 'https://')
           .sub(%r{^git@github.com:}, 'https://github.com/')
  end

  def create_code_location_scan(project, row)
    code_location_id = Enlistment.find_by(project_id: project.to_i)&.code_location_id
    ActiveRecord::Base.connection.execute("

      INSERT INTO code_location_scan (code_location_id, scan_project_id) VALUES
        ( #{code_location_id}, #{row['id']} );

    ")
  end

  def insert_failed_url_data(project, row)
    return unless project.instance_of?(Hash) && (project['name'].to_s.include?("can't be blank")\
                                                || project['enlistments.base'])

    CSV.open('vendor/scan_failed_url.csv', 'a+', write_headers: true, headers: @headers) do |writer|
      writer << [row['name'], row['repo_url']]
    end
  end
end

CreateScanProjectInUi.new.execute
