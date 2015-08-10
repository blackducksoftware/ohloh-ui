require 'test_helper'
require 'test_helpers/commits_by_project_data'

class PeopleDecoratorTest < ActiveSupport::TestCase
  let(:people) { Person.all }
  let(:account) do
    account = create(:account)
    vita = create(:best_vita, account: account)
    create(:vita_fact, vita: vita)
    account.update(best_vita_id: vita.id)
    account
  end

  let(:position1) { create_position(account: account) }
  let(:position2) { create_position(account: account) }

  let(:people_decorator) { PeopleDecorator.new(people) }

  describe 'commits_by_project_map' do
    it 'should return cbp_map' do
      account.best_vita.vita_fact.update(commits_by_project:
                                          CommitsByProjectData.new(position1.id, position2.id).construct)
      people_decorator.commits_by_project_map[account.person.id].must_equal [[position1.id, position2.id], -1]
    end
  end
end
