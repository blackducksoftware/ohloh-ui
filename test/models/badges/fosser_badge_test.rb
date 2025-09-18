# frozen_string_literal: true

require 'test_helper'

class FosserBadgeTest < ActiveSupport::TestCase
  let(:user) { create(:account) }
  let(:fosser_badge) { Badge::FosserBadge.new(user) }

  describe 'eligibility_count' do
    it 'should return positions' do
      create_position(account: user)
      _(fosser_badge.eligibility_count).must_equal 1
    end
  end

  describe 'short_desc' do
    it 'should return string' do
      _(fosser_badge.short_desc).must_equal I18n.t('badges.fosser.short_desc')
    end
  end

  describe 'name' do
    it 'should return name' do
      _(fosser_badge.name).must_equal 'FLOSSer'
    end
  end

  describe 'to_underscore' do
    it 'should return fosser' do
      _(fosser_badge.to_underscore).must_equal 'fosser'
    end
  end

  describe 'level_limits' do
    it 'should return limits' do
      _(fosser_badge.level_limits).must_equal [1, 3, 6, 10, 20, 50, 100, 200]
    end
  end

  describe 'position' do
    it 'should return 60' do
      _(fosser_badge.position).must_equal 60
    end
  end
end
