# frozen_string_literal: true

require 'test_helper'

class TaxonomistBadgeTest < ActiveSupport::TestCase
  let(:user) { create(:account) }
  let(:taxonomist_badge) { TaxonomistBadge.new(user) }

  describe 'eligibility_count' do
    it 'should return project edits with key as tag_list' do
      create(:property_edit, key: 'tag_list', account_id: user.id)
      taxonomist_badge.eligibility_count.must_equal 1
    end
  end

  describe 'short_desc' do
    it 'should return string' do
      taxonomist_badge.short_desc.must_equal I18n.t('badges.taxonomist.short_desc')
    end
  end

  describe 'level_limits' do
    it 'should return limits' do
      taxonomist_badge.level_limits.must_equal [1, 4, 15, 25, 55, 100, 200, 400, 600, 1000, 5000, 10_000]
    end
  end

  describe 'name' do
    it 'should return name' do
      taxonomist_badge.name.must_equal 'TAX(I)onomist'
    end
  end

  describe 'position' do
    it 'should return 70' do
      taxonomist_badge.position.must_equal 70
    end
  end
end
