# frozen_string_literal: true

class Accounts::ChartsController < ApplicationController
  include SetAccountByAccountId

  # NOTE: Replaces accounts#commits_history
  def commits_by_project
    render json: Chart.new(@account).commits_by_project
  end

  def commits_by_individual_project
    render json: ChartDecorator.new.project_commit_history(@account, params[:project_id].to_i)
  end

  # NOTE: Replaces accounts#language_experience
  def commits_by_language
    render json: Chart.new(@account).commits_by_language(params[:scope])
  end
end
