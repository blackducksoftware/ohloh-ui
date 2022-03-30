# frozen_string_literal: true

class OhAdmin::AccountsController < ApplicationController
  before_action :admin_session_required
  layout 'admin'

  def charts
    json_data = Rails.cache.fetch("account_charts_#{params[:period]}", expires_in: 1.day) do
      OhAdmin::AccountChart.new(params[:period].to_i, params[:filter_by]).render
    end
    render json: json_data
  end
end
