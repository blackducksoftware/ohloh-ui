class AccountsController < ApplicationController
  def index
    @persons = Person.claimed(params[:page])
    preload_claimed_persons(@persons)
  end

  private

  def preload_claimed_persons(collection)
    all_position_ids = []

    @cbp_map = collection.each_with_object({}) do |person, cbp_map|
      sorted_cbp = person.account.decorate.sorted_commits_by_project
      position_ids = sorted_cbp.first(3).map(&:first)
      all_position_ids << position_ids
      cbp_map[person.account_id] = [position_ids, sorted_cbp.length - 3]
    end

    @positions_map = Position.where(id: all_position_ids.flatten).includes(:project)
                     .references(:all).index_by(&:id)
  end
end
