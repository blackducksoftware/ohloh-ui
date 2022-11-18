#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

class CreateScanProjectInUi
  include JWTHelper

  def initialize
    @jwt = build_jwt(Account.hamster.login)
    @code_location_ids = nil
  end

  def execute
    CSV.foreach(ARGV[0], headers: true) do |row|
      next if CodeLocationScan.exists?(scan_project_id: row['scan_project_id']) || row['repo_url'].nil?

      code_location_ids(fix_url(row['repo_url']))

      project_id = get_project(row)

      next if project_id.nil?

      handle_response(project_id, row)
    end
  end

  private

  def get_project(row)
    project_id = row['project_id']
    project_id ||= find_existing_project_id if @code_location_ids.present?
    project_id ||= create_scan_project(project_params(row))
    project_id
  end

  def create_scan_project(params)
    uri = URI("#{ENV['URL_HOST']}/api/v1/projects.json")
    response, status = get_result(uri, params)
    code_location_ids(params[:repo_url]) if %w[200 201].include?(status)
    response
  end

  def fix_url(url)
    new_url = url.strip.chomp('/')
    return new_url unless url.match('github.com') || url.match('.git')

    new_url.sub(/\.git$/, '').sub(%r{^git://}, 'https://').sub(%r{^git@github.com:}, 'https://github.com/')
  end

  def handle_response(project_id, row)
    if project_id.instance_of?(Hash)
      insert_failed_url_data(project_id, row)
    else
      create_code_location_scan(project_id, row)
    end
  end

  def create_code_location_scan(project_id, row)
    puts "Project Value #{project_id} row value #{row['name']}"

    code_location_id = Enlistment.not_deleted.where(project_id: project_id,
                                                    code_location_id: @code_location_ids).first&.code_location_id

    code_location_id ||= create_enlistment(row, project_id)

    return unless code_location_id

    CodeLocationScan.where(code_location_id: code_location_id,
                           scan_project_id: row['scan_project_id']).first_or_create
  end

  def insert_failed_url_data(error, row)
    CSV.open('vendor/scan_failed_url.csv', 'a') do |writer|
      writer << [row['name'], row['repo_url'], error]
    end
  end

  def find_existing_project_id
    Project.not_deleted.joins(:enlistments)
           .where(enlistments: { code_location_id: @code_location_ids }).order(updated_at: :desc).first&.id
  end

  def code_location_ids(url)
    @code_location_ids = ApplicationRecord.connection
                                          .execute("select c.id from code_locations c inner join repositories r
                           on r.id = c.repository_id where r.url like '%#{url}%'").values.flatten
  end

  def project_params(row)
    { JWT: @jwt, name: row['name'].sub('/', '-'), vanity_url: row['name'].sub('/', '-'),
      repo_url: fix_url(row['repo_url']), license_name: row['license_name'] }
  end

  def git_branch(url)
    out, _err, _status = Open3.capture3("git ls-remote --symref #{url} HEAD | head -1 | awk '{print $2}'")
    out.strip.sub(/refs\/heads\//, '')
  end

  def create_enlistment(row, project_id)
    params = { url: fix_url(row['repo_url']), scm_type: 'git', branch: git_branch(fix_url(row['repo_url'])),
               project: project_id, JWT: @jwt }
    uri = URI("#{ENV['URL_HOST']}/api/v1/enlistment/enlist.json")

    response, _status = get_result(uri, params)
    return unless response && response['attributes']

    CodeLocationSubscription.create(code_location_id: response['attributes']['id'], client_relation_id: project_id)
    response['attributes']['id']
  end

  def get_result(uri, params)
    response = Net::HTTP.post_form(uri, params)
    [JSON.parse(response.body), response.code]
  rescue StandardError => e
    puts e.message
    nil
  end
end

CreateScanProjectInUi.new.execute
