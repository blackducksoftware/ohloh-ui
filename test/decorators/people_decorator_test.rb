# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/commits_by_project_data'
require 'test_helpers/commits_by_language_data'

class PeopleDecoratorTest < ActiveSupport::TestCase
  describe 'commits_by_project_map' do
    it 'should return cbp_map' do
      account = create_account_with_commits_by_project
      position1 = account.positions.first
      position2 = account.positions.last

      people_decorator = PeopleDecorator.new(Person.all)
      people_decorator.commits_by_project_map[account.person.id].must_equal [[position1.id, position2.id], -1]
    end
  end
end
