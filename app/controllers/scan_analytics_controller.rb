# frozen_string_literal: true

class ScanAnalyticsController < ApplicationController
  helper ProjectsHelper

  before_action :set_project_or_fail
  before_action :analytics_data, only: :index

  def index
    return if @analytics.blank?

    params[:code_set_id] = params[:code_set_id] || @analytics.first.code_set_id
    @scan_data = @analytics.where(code_set_id: params[:code_set_id]).first
  end

  def charts
    return unless @project.coverity_project_id

    scan_project_id = params[:scan_id].presence || @project.coverity_project_id
    api_response(scan_project_id)
  end

  private

  def analytics_data
    @analytics = @project.best_analysis&.scan_analytics&.analytics&.order(id: :asc)
  end

  def api_response(scan_project_id)
    return unless scan_project_id

    uri = URI.parse("#{ENV['COVERITY_SCAN_URL']}/api/projects/#{scan_project_id}/charts?format=json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.get(uri.request_uri)
    render json: JSON.parse(response.body) if response.code == '200'
  end
end
