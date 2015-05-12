class PeopleController < UnclaimedController
  helper KudosHelper

  before_action :find_index_people, only: [:index]
  before_action :preload_data, only: [:index]
  before_action :find_rankings_people, only: [:rankings]

  private

  def find_index_people
    @claimed_people = Person.find_claimed(params[:q], 'relevance').paginate(page: 1, per_page: 3)
    @unclaimed_people = Person.find_unclaimed(q: params[:q], find_by: 'relevance', per_page: 3)
    @unclaimed_people_count = Person::Count.unclaimed_by(params[:q], 'relevance')
  end

  def preload_data
    preload_emails_from_unclaimed_people
    @cbp_map = PeopleDecorator.new(@claimed_people).commits_by_project_map
    @positions_map = Position.where(id: @cbp_map.values.map(&:first).flatten).includes(:project)
                     .references(:all).index_by(&:id)
  end

  def find_rankings_people
    @people = Person.tsearch(params[:query], "sort_by_#{params[:sort] || 'kudo_position'}")
              .paginate(page: params[:page] || 1, per_page: 10)
  end
end
