require 'test_helper'

class ReverificationTrackerTest < ActiveSupport::TestCase

  describe 'cleanup' do
    it 'should destroy all reverification trackers if account verified' do
      verified = create(:reverification_tracker)
      unverified = create(:initial_rev_tracker)
      assert verified.account.access.mobile_or_oauth_verified?
      ReverificationTracker.cleanup
      assert_equal 1, ReverificationTracker.count
    end
  end
end
