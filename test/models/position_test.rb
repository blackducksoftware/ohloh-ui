require 'test_helper'

class PositionTest < ActiveSupport::TestCase
  it 'claimed_by scope' do
    user = accounts(:user)
    positions = Position.claimed_by(user)

    positions.count.must_equal 1
    positions.first.account_id.must_equal user.id
    positions.first.name_id.must_be :present?
  end

  it 'active scope' do
    accounts(:user).positions.active.count.must_equal 0
    linux = projects(:linux)
    linux.editor_account = accounts(:user)
    linux.update!(best_analysis_id: 1)
    accounts(:user).positions.active.count.must_equal 1
  end

  it '#for_project' do
    user = create(:account)
    proj = create(:project)
    create(:position, account: user, project: proj)
    Position.for_project(proj).claimed_by(user).count.must_equal 1
  end
end
