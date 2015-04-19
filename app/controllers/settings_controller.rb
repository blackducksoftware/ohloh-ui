class SettingsController < ApplicationController
  # NOTE: renamed disable_oversized_projects to oversized_project?
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
    return if @project.best_analysis.logged_at.nil?

    time_span = time_span.to_s.split
    @highlight_from = @project.best_analysis.logged_at - time_span.first.to_i.send(time_span.last)
  end
end
