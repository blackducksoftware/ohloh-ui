class AccountsController < ApplicationController
  def index
    @accounts = Person.claimed(params[:page] || 1)
    preload_claimed_persons(@accounts)
    load_logos
  end

  private

  def preload_claimed_persons(collection)
    all_position_ids = []

    @cbp_map = collection.inject({}) do |cbp_map, p|
      cbp = p.account.symbolized_commits_by_project
      sorted_cbp = cbp.inject({}) do |res, hsh|
        pos_id = hsh[:position_id].to_i
        res[pos_id] ||= 0
        res[pos_id] += hsh[:commits].to_i
        res
      end.sort_by { |k, v| v }.reverse

      position_ids = sorted_cbp.first(3).map(&:first)
      all_position_ids << position_ids
      cbp_map[p.account_id] = [position_ids, sorted_cbp.length - 3]
      cbp_map
    end

    @positions_map = Position.where{id.in all_position_ids.flatten}.includes(:project)
                             .references(:all).index_by(&:id)
  end

  def load_logos
    @logos_map = Logo.where{id.in @logo_ids}.index_by(&:id)
    @logo_ids = nil
  end
end
