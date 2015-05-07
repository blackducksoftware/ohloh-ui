class PeopleController < UnclaimedController
  before_action :find_people, only: [:index]
  before_action :preload_data, only: [:index]

  private

  def find_people
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
end
