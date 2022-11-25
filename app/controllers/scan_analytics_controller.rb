# frozen_string_literal: true

class ScanAnalyticsController < ApplicationController
  helper ProjectsHelper

  before_action :set_project_or_fail

  def index
    @analytics = @project.best_analysis&.scan_analytics&.analytics
    return if @analytics.blank?

    params[:code_set_id] ||= @analytics.first.code_set_id
    @scan_data = @analytics.find_by(code_set_id: params[:code_set_id])
  end

  def charts
    scan_charts = @project.best_analysis&.scan_analytics&.charts
    return render json: I18n.t('.no_data'), status: :bad_request if scan_charts.blank?

    scan_charts = scan_charts.where(code_set_id: params[:code_set_id]) if params[:code_set_id]
    render json: JSON.parse(scan_charts.first&.data || '{}')
  end
end
