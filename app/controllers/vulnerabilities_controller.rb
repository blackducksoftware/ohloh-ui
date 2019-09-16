# frozen_string_literal: true

class VulnerabilitiesController < ApplicationController
  layout 'responsive_project_layout', only: [:index]
  helper ProjectsHelper

  include VulnerabilityFilters
  include VulnerabilitiesHelper

  def recent_version_chart
    @releases = @best_security_set.most_recent_releases
    release_history = @best_security_set.release_history(@releases.map(&:id))
    render json: Vulnerability::RecentVersionChart.new(release_history).data
  end

  def index
    @release_history = @best_security_set.try(:release_history) || []
  end

  def filter
    find_vulnerabilities
    render partial: 'vulnerability_table', layout: false
  end
end
