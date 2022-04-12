# frozen_string_literal: true

# :nocov:

class OhAdmin::ProjectsController < ApplicationController
  before_action :admin_session_required
  layout 'admin'

  def charts
    json_data = Rails.cache.fetch("project_charts_#{params[:period]}_#{params[:filter_by]}", expires_in: 1.day) do
      OhAdmin::ProjectChart.new(params[:period].to_i, params[:filter_by]).render
    end
    render json: json_data
  end
end
# :nocov:
