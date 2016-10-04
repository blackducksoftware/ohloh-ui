class VulnerabilitiesController < ApplicationController
  layout 'responsive_project_layout', only: [:index]

  include VulnerabilityFilters, VulnerabilitiesHelper

  def all_version_chart
    @releases = @releases.order(released_on: :asc) if @releases.present?
    render json: Vulnerability::AllVersionChart.new(@releases, @best_security_set).data
  end

  def recent_version_chart
    @releases = @best_security_set.most_recent_releases if @best_security_set
    render json: Vulnerability::RecentVersionChart.new(@releases, @best_security_set).data
  end

  def filter
    render partial: 'vulnerability_table', layout: false
  end
end
