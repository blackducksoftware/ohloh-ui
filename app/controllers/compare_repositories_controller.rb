class CompareRepositoriesController < ApplicationController
  before_action :tool_context, only: :index

  def index; end

  def chart
    render json: RepositoryComparisionChart.build.to_json, layout: false
  end
end
