class Accounts::ChartsController < ApplicationController
  include SetAccountByAccountId
  include RedirectIfDisabled

  before_action :redirect_if_disabled

  def commits_by_project
    render json: Chart.new(@account).commits_by_project
  end

  def commits_by_language
    render json: Chart.new(@account).commits_by_language(params[:scope])
  end
end
