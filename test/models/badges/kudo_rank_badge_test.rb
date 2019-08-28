# frozen_string_literal: true

require 'test_helper'

class KudoRankBadgeTest < ActiveSupport::TestCase
  let(:user) { create(:account) }
  let(:kudo_rank_badge) { KudoRankBadge.new(user) }

  describe 'eligibility_count' do
    it 'should return account kudo_rank' do
      kudo_rank_badge.eligibility_count.must_equal user.kudo_rank
    end
  end

  describe 'short_desc' do
    it 'should return empty string' do
      kudo_rank_badge.short_desc.must_equal ''
    end
  end

  describe 'levels?' do
    it 'should return true' do
      kudo_rank_badge.levels?.must_equal true
    end
  end

  describe 'level' do
    it 'should return account kudo_rank' do
      kudo_rank_badge.level.must_equal user.kudo_rank
    end
  end

  describe 'position' do
    it 'should return 80' do
      kudo_rank_badge.position.must_equal 80
    end
  end
end
