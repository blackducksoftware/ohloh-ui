class AccountsController < ApplicationController
  # NOTE: uncomment account_context while migrating account's show action
  # before_action :account_context, only: [:show]

  def index
    @people = Person.find_claimed(page: params[:page])
    @cbp_map = PeopleDecorator.decorate(@people).commits_by_project_map
    @positions_map = Position.where(id: @cbp_map.values.map(&:first).flatten).includes(:project)
                     .references(:all).index_by(&:id)
  end
end
