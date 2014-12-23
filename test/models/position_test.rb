require 'test_helper'

class PositionTest < ActiveSupport::TestCase
  fixtures :accounts, :projects

  test 'claimed_by scope' do
    user = accounts(:user)
    positions = Position.claimed_by(user)

    assert_equal 1, positions.count
    assert_equal user.id, positions.first.account_id
    assert positions.first.name_id
  end

  test 'active scope' do
    assert_equal 0, accounts(:user).positions.active.count
    projects(:linux).update!(best_analysis_id: 1)
    assert_equal 1, accounts(:user).positions.active.count
  end
end
