require 'test_helper'

class DescriberBadgeTest < ActiveSupport::TestCase
  let(:user) do
    account = create(:account)
    Edit.create!(target_type: 'Project', key: 'description', target_id: create(:project).id, account_id: account.id)
    account
  end

  let(:describer_badge) { DescriberBadge.new(user) }

  describe 'eligibility_count' do
    it 'should return project description edits' do
      describer_badge.eligibility_count.must_equal 1
    end
  end

  describe 'short_desc' do
    it 'should return string' do
      describer_badge.short_desc.must_equal 'edits project descriptions'
    end
  end

  describe 'level_limits' do
    it 'should return limits' do
      describer_badge.level_limits.must_equal [1, 4, 10, 20, 50, 100, 200, 400, 600, 800]
    end
  end

  describe 'position' do
    it 'should return 10' do
      describer_badge.position.must_equal 10
    end
  end
end
