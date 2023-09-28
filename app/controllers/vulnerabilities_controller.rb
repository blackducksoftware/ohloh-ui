# frozen_string_literal: true

class VulnerabilitiesController < ApplicationController
  layout 'responsive_project_layout', only: [:index]
  helper ProjectsHelper

  include VulnerabilityFilters
  include VulnerabilitiesHelper

  def recent_version_chart
    @releases = @best_security_set.most_recent_releases
    release_history = @best_security_set.release_history(@releases.map(&:id), @bdsa_visible)
    render json: Vulnerability::RecentVersionChart.new(release_history, @bdsa_visible).data
  end

  def index
    @release_history = @best_security_set.try(:release_history, [], @bdsa_visible) || []
  end

  def filter
    find_vulnerabilities
    @release ||= Release.find_by(id: filter_version_param)
    render partial: 'vulnerability_table', layout: false
  end
end
