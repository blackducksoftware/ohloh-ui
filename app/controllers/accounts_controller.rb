class AccountsController < ApplicationController
  before_action :account, only: [:show, :commits_by_project_chart, :commits_by_language_chart]
  before_action :redirect_if_disabled, only: [:show, :commits_by_project_chart, :commits_by_language_chart]
  # before_action :account_context, only: [:show]

  def index
    @people = Person.find_claimed(page: params[:page])
    @cbp_map = PeopleDecorator.new(@people).commits_by_project_map
    @positions_map = Position.where(id: @cbp_map.values.map(&:first).flatten).includes(:project)
                     .references(:all).index_by(&:id)
  end

  def show
    @projects, @logos = @account.project_core.used
    @twitter_detail = TwitterDetail.new(@account)
  end

  # NOTE: Replaces commits_history
  def commits_by_project_chart
    render json: Chart.new(@account).commits_by_project
  end

  # NOTE: Replaces language_experience
  def commits_by_language_chart
    render json: Chart.new(@account).commits_by_language(params[:scope])
  end

  private

  def account
    accounts = Account.arel_table
    @account = Account.where(accounts[:id].eq(params[:id]).or(accounts[:login].eq(params[:id]))).first
  end

  def redirect_if_disabled
    redirect_to disabled_account_url(@account) if @account && Account::Access.new(@account).disabled?
  end
end
