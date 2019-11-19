# frozen_string_literal: true

class CompareRepositoriesController < ApplicationController
  before_action :tool_context, only: :index

  def chart
    render json: RepositoryComparisionChart.build.to_json, layout: false
  end
end
