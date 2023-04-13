#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

class CreateUiProjectInScan
  include JWTHelper

  def initialize
    @jwt = build_jwt(Account.hamster.login)
    to = Date.yesterday.end_of_month
    from = 6.months.ago.to_date.beginning_of_month
    @project = Project.with_important_code_locations.joins(:best_analysis)
                      .where('analyses.created_at >= ? AND analyses.created_at <= ?', from, to)
  end

  def execute
    @project.each do |project|
      puts "Project ID #{project.vanity_url}"
      project.fis_code_locations.where(is_important: true).each do |code_location|
        url = CodeLocation.find(code_location.id).url
        params = { JWT: @jwt, url: url, user_id: ENV['SECRET_USER_KEY'] }
        uri = URI("#{ENV['URL_HOST']}/api/v1/projects/#{project.vanity_url}/create_scan_project.json")
        get_result(uri, params)
      end
    end
  end

  private

  def get_result(uri, params)
    Net::HTTP.post_form(uri, params)
  rescue StandardError => e
    puts e.message
  end
end
CreateUiProjectInScan.new.execute
