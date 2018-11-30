class SettingsController < ApplicationController
  before_action :show_permissions_alert, only: %i[index new edit]
  ACCEPTABLE_TIME_UNITS = %w[hours days weeks months years].freeze

  def oversized_project?(project)
    return true if defined?(OVERSIZED_PROJECT_IDS) && OVERSIZED_PROJECT_IDS.include?(project.id)
  end

  def set_sort_and_highlight
    time_span = /[0-9]+ [a-z]+/.match(params[:time_span])
    return unless time_span
    return if params[:time_span].blank? || @project.best_analysis.nil?

    parse_time_span(time_span.to_s)
  end

  private

  def parse_time_span(time_span)
    return unless @project.best_analysis.oldest_code_set_time
    @highlight_from =
      @project.best_analysis.oldest_code_set_time - time_span.to_s.split.first.to_i.send(time_units(time_span))
  end

  def time_units(time_span)
    units = time_span.to_s.split.last
    units = 'months' unless ACCEPTABLE_TIME_UNITS.include?(units)
    units
  end
end
