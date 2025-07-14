#! /usr/bin/env ruby
# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength

require_relative '../config/environment'
require 'logger'
require 'open3'

class AddGithubCodeLocations
  def initialize
    @log = Logger.new('log/apache_github_code_locations_added.log')
    @failed_log = Logger.new('log/apache_github_code_locations_not_added.log')
  end

  def execute
    filename = ARGV[0]
    CSV.foreach(filename, headers: true) do |row|
      if row['in_github_as'] != 'False'
        url = "https://github.com/apache/#{row['in_github_as']}"
        code_location_id = create_code_location(url)
        next unless code_location_id

        Enlistment.not_deleted.where(code_location_id: row['code_location_id'].to_i).find_each do |en|
          create_enlistment_for_project(en.project_id, code_location_id)
          delete_subscription(en.project_id, row['code_location_id'].to_i)
        end

        log_detail(code_location_id, url)
      end
    end
  end

  private

  def create_enlistment_for_project(project_id, code_location_id)
    enlistment = Enlistment.where(project_id: project_id, code_location_id: code_location_id).first_or_initialize
    enlistment.editor_account = Account.hamster
    create_subscription(project_id, code_location_id) if enlistment.save
  end

  def create_code_location(url)
    branch = git_branch(url)
    return if branch.blank?

    params = { url: url, scm_type: 'git', branch: branch }
    response = Net::HTTP.post_form(code_location_uri, params)
    hsh = JSON.parse(response.body)
    hsh['code_location_id']
  rescue StandardError => e
    puts e.message
  end

  def git_branch(url)
    out, _err, _status = Open3.capture3("git ls-remote --symref #{url} HEAD | head -1 | awk '{print $2}'")
    out.strip.gsub('refs/heads/', '')
  end

  def code_location_uri
    query = { api_key: ENV.fetch('EFISBOT_API_TOKEN', nil) }
    URI("#{ENV.fetch('FISBOT_API_URL', nil)}/code_locations.json?#{query.to_query}")
  end

  def create_subscription(project_id, code_location_id)
    params = { code_location_id: code_location_id, client_relation_id: project_id }
    CodeLocationSubscription.create(params)
  end

  def delete_subscription(project_id, code_location_id)
    params = { code_location_id: code_location_id, client_relation_id: project_id }
    CodeLocationSubscription.new(params).delete
  end

  def log_detail(code_location_id, url)
    if code_location_id
      @log.info("#{code_location_id}, #{url}")
    else
      @failed_log.info(url)
    end
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength

AddGithubCodeLocations.new.execute
