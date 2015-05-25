class PeopleController < UnclaimedController
  helper KudosHelper

  before_action :find_index_people, only: [:index]
  before_action :preload_data, only: [:index]
  before_action :find_rankings_people, only: [:rankings]

  private

  def find_index_people
    @claimed_people = Person.find_claimed(params[:query], 'relevance')
                      .preload(account: [:projects, :markup])
                      .paginate(page: 1, per_page: 3)
    @unclaimed_people = Person.find_unclaimed(q: params[:query], find_by: 'relevance', per_page: 3)
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
              .paginate(page: params[:page], per_page: 10)
  end

  def parse_sort_term
    Person.respond_to?("sort_by_#{params[:sort]}") ? "sort_by_#{params[:sort]}" : 'sort_by_kudo_position'
  end
end
