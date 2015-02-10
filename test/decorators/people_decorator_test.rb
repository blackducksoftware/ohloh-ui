require 'test_helper'

class PeopleDecoratorTest < ActiveSupport::TestCase
  let(:people) { Person.all }
  let(:user) { accounts(:user) }
  let(:people_decorator) { PeopleDecorator.new(people) }

  let(:cbp) do
    [{ 'month' => Time.parse('2010-04-30 20:00:00 -0400'), 'commits' => '1', 'position_id' => '3' },
     { 'month' => Time.parse('2010-04-30 20:00:00 -0400'), 'commits' => '6', 'position_id' => '1' },
     { 'month' => Time.parse('2011-01-01 00:00:00'), 'commits' => '1', 'position_id' => '3' },
     { 'month' => Time.parse('2012-11-01 00:00:00'), 'commits' => '1', 'position_id' => '1' }]
  end

  let(:cbp_map) do
    { 1 => [[], -3], 2 => [[1, 3], -1], 3 => [[], -3], 4 => [[], -3], 5 => [[], -3], 6 => [[], -3], 7 => [[], -3] }
  end

  describe 'commits_by_project_map' do
    it 'should return cbp_map' do
      user.best_vita.vita_fact.update(commits_by_project: cbp)
      people_decorator.commits_by_project_map.must_equal cbp_map
    end
  end
end
