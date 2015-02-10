require 'test_helper'

class PositionDecoratorTest < ActiveSupport::TestCase
  let(:user) { accounts(:user) }
  let(:admin) { accounts(:admin) }

  let(:cbp) do
    [{ 'month' => Time.parse('2010-04-30 20:00:00 -0400'), 'commits' => '1', 'position_id' => '3' },
     { 'month' => Time.parse('2010-04-30 20:00:00 -0400'), 'commits' => '6', 'position_id' => '1' },
     { 'month' => Time.parse('2011-01-01 00:00:00'), 'commits' => '1', 'position_id' => '3' },
     { 'month' => Time.parse('2012-11-01 00:00:00'), 'commits' => '1', 'position_id' => '1' }]
  end

  describe 'analyzed?' do
    it 'should return false when position is not analyzed' do
      admin.positions.first.decorate.analyzed?.must_equal false
    end

    it 'should return true when position is analyzed' do
      user.best_vita.vita_fact.update(commits_by_project: cbp)
      user.positions.first.decorate.analyzed?.must_equal true
    end
  end
end
