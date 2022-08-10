# frozen_string_literal: true

class PeopleController < UnclaimedController
  helper KudosHelper

  before_action :find_index_people, unless: :query_or_cache_exist, only: [:index]
  before_action :preload_data, unless: :query_or_cache_exist, only: [:index]
  before_action :find_rankings_people, only: [:rankings]

  def rankings; end

  private

  def query_or_cache_exist
    params[:query].blank? && Rails.cache.exist?('people_index_page') && Rails.cache.exist?('people_index_page_device')
  end

  def find_index_people
    @claimed_people = Person.find_claimed(params[:query], 'relevance')
                            .preload(account: :markup)
                            .paginate(page: 1, per_page: 3)
    @unclaimed_people = unclaimed_people(params[:query], 'relevance', 3)
    @unclaimed_people_count = Person::Count.unclaimed_by(params[:query], 'relevance')
  end

  def preload_data
    preload_emails_from_unclaimed_people
    @cbp_map = PeopleDecorator.new(@claimed_people).commits_by_project_map
    @positions_map = Position.where(id: @cbp_map.values.map(&:first).flatten)
                             .preload(project: [{ best_analysis: :main_language }, :logo])
                             .index_by(&:id)
  end

  def find_rankings_people
    @people = Person.includes(:account).references(:all)
                    .filter_by(params[:query]).send(parse_sort_term)
                    .paginate(page: page_param, per_page: 10)
  end

  def parse_sort_term
    Person.respond_to?("sort_by_#{params[:sort]}") ? "sort_by_#{params[:sort]}" : 'sort_by_kudo_position'
  end
end
