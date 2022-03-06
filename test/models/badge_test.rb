# frozen_string_literal: true

require 'test_helper'

class BadgeTest < ActiveSupport::TestCase
  describe 'BadgeTest' do
    let(:account) { create(:account) }
    let(:badge) { Badge.new(account, desc_edit_count: 10, manages_proj_count: 3) }
    let(:kudo_badge) { KudoRankBadge.new(account) }

    it 'should initializes a new BadgeObject' do
      _(badge.account.id).must_equal account.id
      _(badge.vars).must_be_kind_of Hash
      _(badge.vars[:desc_edit_count]).must_equal 10
      _(badge.account.id).must_equal account.id
    end

    it 'should display in a specified order' do
      _(Badge.ordered_badges).must_be_kind_of Array
      _(Badge.ordered_badges.length).must_equal 8
    end

    it 'should display all the eligible badges for a account' do
      badges = Badge.all_eligible(account)
      _(badges).must_be_kind_of Array
      _(badges.length).must_equal 1 # place holder it would change when implementing other badges
      _(badges.first).must_be_kind_of KudoRankBadge
    end

    it 'should display the description of a badge' do
      _(kudo_badge.description(false)).must_equal 'Level 1'
      _(kudo_badge.description(true)).must_equal 'Level 1 Kudo Rank'
    end

    it 'should test it has levels' do
      Badge.any_instance.stubs(:level_limits).returns([10, 20, 30])
      Badge.any_instance.stubs(:eligibility_count).returns(10)
      _(badge.level).must_equal 1
    end

    it 'should test the level and level bits' do
      _(kudo_badge.level).must_equal 1
      _(kudo_badge.eligibility_count).must_equal 1
      _(kudo_badge.level_bits).must_equal '0001'
    end

    it 'should raise a error on short_desc' do
      _(-> { badge.short_desc }).must_raise RuntimeError
    end

    it 'should test the string' do
      _(badge.to_underscore).must_be_empty
      _(kudo_badge.to_underscore).must_equal 'kudo_rank'
    end
  end
end
