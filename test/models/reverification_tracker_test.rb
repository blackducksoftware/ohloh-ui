require 'test_helper'

class ReverificationTrackerTest < ActiveSupport::TestCase

  describe 'initial phase accounts' do
    it 'should find the correct accounts that have a rev_tracker of initial' do
      create(:account) #Wrong
      create(:unverified_account) # Wrong
      create(:initial_rev_tracker) # Wrong
      create(:soft_bounce_initial_rev_tracker) # Correct
      correct_rev_tracker = ReverificationTracker.initial_soft_bounced(4).first
      assert_equal correct_rev_tracker, ReverificationTracker.initial_soft_bounced(4).first
      assert correct_rev_tracker.soft_bounced?
      assert correct_rev_tracker.initial?
    end
  end

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
