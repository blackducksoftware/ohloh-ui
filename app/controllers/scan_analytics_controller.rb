# frozen_string_literal: true

class ScanAnalyticsController < ApplicationController
  helper ProjectsHelper

  before_action :set_project_or_fail

  def index
    @analytics = @project.best_analysis&.scan_analytics&.analytics

    params[:code_set_id] ||= @analytics.first.code_set_id
    @scan_data = @analytics.find_by(code_set_id: params[:code_set_id])
  end

  def charts
    scan_charts = @project.best_analysis&.scan_analytics&.charts
    scan_charts = scan_charts.where(code_set_id: params[:code_set_id]) if params[:code_set_id]
    charts_data = scan_charts.first&.data
    render json: JSON.parse(charts_data) if charts_data
  end
end
