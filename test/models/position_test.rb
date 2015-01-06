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
    projects(:linux).update!(best_analysis_id: 1)
    accounts(:user).positions.active.count.must_equal 1
  end
end
