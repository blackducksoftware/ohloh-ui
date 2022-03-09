# frozen_string_literal: true

require 'test_helper'

describe ProjectBadge do
  describe 'project_name' do
    it 'should create a project badge' do
      assert_difference('ProjectBadge.count', 1) { create(:travis_badge, enlistment: create(:enlistment)) }
    end

    it 'should not create a project badge if params is invalid' do
      badge = TravisBadge.new(identifier: '', enlistment: create(:enlistment))
      assert_difference('ProjectBadge.count', 0) { badge.save }
      _(badge.errors[:identifier]).must_be :present?
    end

    it 'should not create a project badge if type is empty' do
      badge = ProjectBadge.new(identifier: '1', enlistment: create(:enlistment))
      assert_difference('ProjectBadge.count', 0) { badge.save }
      _(badge.errors[:type]).must_be :present?
    end
  end
end
