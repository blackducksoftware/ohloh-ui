class AccountsController < ApplicationController
  def index
    @people = Person.claimed(params[:page])
    @cbp_map = PeopleDecorator.decorate(@people).commits_by_project_map
    @positions_map = Position.where(id: @cbp_map.values.map(&:first).flatten).includes(:project)
                     .references(:all).index_by(&:id)
  end
end
