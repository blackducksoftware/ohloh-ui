class PeopleDecorator < Draper::CollectionDecorator
  def commits_by_project_map
    object.each_with_object({}) do |person, cbp_map|
      account = person.account.decorate
      sorted_cbp = account.sorted_commits_by_project
      cbp_map[account.id] = [sorted_cbp.first(3).map(&:first), sorted_cbp.length - 3]
    end
  end
end
