class CompareController < ApplicationController
  helper CsvHelper
  helper ProjectsHelper
  helper RatingsHelper
  before_action :find_projects, only: [:projects_graph]

  before_action :setup_header, only: [:projects]

  def projects
    @projects = [Project.where(name: params[:project_0]).first,
                 Project.where(name: params[:project_1]).first,
                 Project.where(name: params[:project_2]).first]
  end

  def projects_graph
    @metric = params[:project_data][:metric]
    populate_chart_plot_points_and_series(@projects)
  end

  private

  def find_projects
    @projects = [Project.where(name: params[:project_0]).first,
                 Project.where(name: params[:project_1]).first,
                 Project.where(name: params[:project_2]).first]
  end

  def populate_chart_plot_points_and_series(projects)
    set_date_ranges
    @series_of_plot_points = {}
    projects.each do |project|
      next if project.nil? || project.best_analysis.nil?
      data = project.best_analysis.send("#{@metric.downcase.singularize}_history".to_sym, @start_date, @end_date)
      @series_of_plot_points[project.name] = data.map { |values| values["#{@metric.downcase}"].to_i }
      @series_of_plot_points[project.name].pop
    end
  end

  def set_date_ranges
    present_date = Time.now.utc
    @end_date = Time.now.utc.strftime('%Y-%m-01')
    @start_date = Time.utc(present_date.year - 3, present_date.month).strftime('%Y-%m-01')
  end

  def setup_header
    return unless request_format == 'csv'
    response.content_type = 'text/csv'
    response.headers['Content-Disposition'] = 'attachment; filename="export_compare.csv"'
  end
end
