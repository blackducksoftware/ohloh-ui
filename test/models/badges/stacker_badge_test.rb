require 'test_helper'

class StackerBadgeTest < ActiveSupport::TestCase
  let(:user) { create(:account) }
  let(:stacker_badge) { StackerBadge.new(user) }

  describe 'eligibility_count' do
    it 'should return account stacks' do
      stacker_badge.eligibility_count.must_equal 0
    end
  end

  describe 'short_desc' do
    it 'should return string' do
      stacker_badge.short_desc.must_equal 'stacks projects'
    end
  end

  describe 'level_limits' do
    it 'should return limits' do
      stacker_badge.level_limits.must_equal [1, 2, 3, 4, 5]
    end
  end

  describe 'position' do
    it 'should return 40' do
      stacker_badge.position.must_equal 40
    end
  end
end
