class CompareController < ApplicationController
  helper CsvHelper
  helper ProjectsHelper
  helper RatingsHelper

  before_action :setup_header, only: [:projects]

  def projects
    @projects = [Project.where(name: params[:project_0]).first,
                 Project.where(name: params[:project_1]).first,
                 Project.where(name: params[:project_2]).first]
  end

  private

  def setup_header
    return unless request_format == 'csv'
    response.content_type = 'text/csv'
    response.headers['Content-Disposition'] = 'attachment; filename="export_compare.csv"'
  end
end
