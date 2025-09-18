# frozen_string_literal: true

class ComparesController < ApplicationController
  helper CsvHelper
  helper ProjectsHelper
  helper RatingsHelper
  before_action :setup_header, only: [:projects]
  skip_before_action :verify_authenticity_token, only: [:projects_graph]

  def projects
    find_projects
    save_session_projects unless bot?
  end

  def projects_graph
    @metric = params[:metric]
    find_projects
    set_date_ranges
    populate_chart_plot_points_and_series
  end

  private

  def save_session_projects
    session[:session_projects] = @projects.map(&:to_param)
  end

  def find_projects
    @projects = [params[:project_0], params[:project_1], params[:project_2]].map do |project_param|
      project_param.blank? ? nil : Project.case_insensitive_name(project_param).take
    end
  end

  def populate_chart_plot_points_and_series
    @series_of_plot_points = {}
    @projects.compact.each do |project|
      @series_of_plot_points[project.name] = if project.nil? || project.best_analysis.nil?
                                               []
                                             else
                                               metric_data(@metric, project)
                                             end
      @series_of_plot_points[project.name].pop
    end
  end

  def set_date_ranges
    present_date = Time.current
    @end_date = Time.current.strftime('%Y-%m-01')
    @start_date = Time.utc(present_date.year - 3, present_date.month).strftime('%Y-%m-01')
  end

  def setup_header
    return unless request_format == 'csv'

    response.content_type = 'text/csv'
    response.headers['Content-Disposition'] = 'attachment; filename="export_compare.csv"'
  end

  def metric_data(metric_name, project)
    return [] unless metric_name

    data = project.best_analysis.send(:"#{metric_name}_history", @start_date, @end_date)
    data.map do |values|
      metric_name == 'code_total' ? values['code_total'].to_i : values[metric_name.pluralize.to_s].to_i
    end
  end
end
