# frozen_string_literal: true

require 'test_helper'

class OrgManagerBadgeTest < ActiveSupport::TestCase
  let(:user) { create(:account) }
  let(:org) { create(:organization) }
  let(:org_manager_badge) { OrgManagerBadge.new(user) }

  describe 'eligibility_count' do
    it 'should return orgs managed by account' do
      create(:manage, account: user, target: org)
      _(org_manager_badge.eligibility_count).must_equal 1
    end
  end

  describe 'short_desc' do
    it 'should return string' do
      _(org_manager_badge.short_desc).must_equal I18n.t('badges.org_manager.short_desc')
    end
  end

  describe 'name' do
    it 'should return string' do
      _(org_manager_badge.name).must_equal 'Org Man'
    end
  end

  describe 'position' do
    it 'should return 50' do
      _(org_manager_badge.position).must_equal 50
    end
  end
end
