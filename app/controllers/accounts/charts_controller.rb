class Accounts::ChartsController < AccountsController
  include SetAccountByAccountId

  before_action :redirect_if_disabled

  # NOTE: Replaces accounts#commits_history
  def commits_by_project
    render json: Chart.new(@account).commits_by_project
  end

  # NOTE: Replaces accounts#language_experience
  def commits_by_language
    render json: Chart.new(@account).commits_by_language(params[:scope])
  end
end
