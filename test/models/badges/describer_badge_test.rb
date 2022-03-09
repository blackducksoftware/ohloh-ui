# frozen_string_literal: true

require 'test_helper'

class DescriberBadgeTest < ActiveSupport::TestCase
  let(:user) { create(:account) }
  let(:describer_badge) { DescriberBadge.new(user) }

  describe 'eligibility_count' do
    it 'should return project description edits' do
      create(:property_edit, key: 'description', account_id: user.id)
      _(describer_badge.eligibility_count).must_equal 1
    end
  end

  describe 'short_desc' do
    it 'should return string' do
      _(describer_badge.short_desc).must_equal I18n.t('badges.describer.short_desc')
    end
  end

  describe 'level_limits' do
    it 'should return limits' do
      _(describer_badge.level_limits).must_equal [1, 4, 10, 20, 50, 100, 200, 400, 600, 800]
    end
  end

  describe 'position' do
    it 'should return 10' do
      _(describer_badge.position).must_equal 10
    end
  end
end
