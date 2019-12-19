# frozen_string_literal: true

require 'test_helper'

class ProjectManagerBadgeTest < ActiveSupport::TestCase
  let(:user) { create(:account) }
  let(:project) { create(:project) }
  let(:project_manager_badge) { ProjectManagerBadge.new(user) }

  describe 'eligibility_count' do
    it 'should return managed projects' do
      create(:manage, account: user, target: project)
      project_manager_badge.eligibility_count.must_equal 1
    end
  end

  describe 'short_desc' do
    it 'should return string' do
      project_manager_badge.short_desc.must_equal I18n.t('badges.project_manager.short_desc')
    end
  end

  describe 'name' do
    it 'should return name' do
      project_manager_badge.name.must_equal 'Big Cheese'
    end
  end

  describe 'position' do
    it 'should return 30' do
      project_manager_badge.position.must_equal 30
    end
  end
end
