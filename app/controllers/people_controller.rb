class PeopleController < UnclaimedController
  helper KudosHelper

  before_action :set_claimed_people, :set_unclaimed_people, only: :index
  before_action :preload_data, only: [:index]
  before_action :find_rankings_people, only: [:rankings]

  private

  def set_claimed_people
    @claimed_people = Rails.cache.fetch('people_index_claimed', expires_in: 4.hours) do
      Person.find_claimed(params[:query], 'relevance').preload(account: [:projects, :markup])
      .paginate(page: 1, per_page: 3)
    end
  end

  def set_unclaimed_people
    @unclaimed_people = Rails.cache.fetch('people_index_unclaimed', expires_in: 4.hours) do
      Person.find_unclaimed(q: params[:query], find_by: 'relevance', per_page: 3)
    end

    @unclaimed_people_count = Rails.cache.fetch('people_index_unclaimed_count', expires_in: 4.hours) do
      Person::Count.unclaimed_by(params[:query], 'relevance')
    end
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
