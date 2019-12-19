# frozen_string_literal: true

class PeopleDecorator
  def initialize(people)
    @people = people
  end

  def commits_by_project_map
    @people.each_with_object({}) do |person, cbp_map|
      account_decorator = person.account.decorate
      sorted_cbp = account_decorator.sorted_commits_by_project
      cbp_map[person.account_id] = [sorted_cbp.first(3).map(&:first), sorted_cbp.length - 3]
    end
  end
end
