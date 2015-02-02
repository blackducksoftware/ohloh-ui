class AccountsController < ApplicationController
  before_action :redirect_if_disabled, only: :show
  before_action :account_context, only: [:show]

  def index
    @people = Person.find_claimed(page: params[:page])
    @cbp_map = PeopleDecorator.decorate(@people).commits_by_project_map
    @positions_map = Position.where(id: @cbp_map.values.map(&:first).flatten).includes(:project)
                     .references(:all).index_by(&:id)
  end

  def show
    @projects, @logos = @account.project_core.used
  end

  private

  def redirect_if_disabled
    @account = Account.where(id: params[:id]).first
    redirect_to :disabled if @account && @account.disabled?
  end
end
