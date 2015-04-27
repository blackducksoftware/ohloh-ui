require 'test_helper'
class RecentlyActiveAccountsCacheTest < ActiveSupport::TestCase
  let(:account) { create(:account) }

  describe 'Recently ActiveAccounts Cache ' do
    it 'should be blank initially' do
      RecentlyActiveAccountsCache.accounts.must_equal []
    end

    it 'should retrive the first record' do
      name_facts(:vitafact).update_attributes(last_checkin: Time.now)
      RecentlyActiveAccountsCache.recalc!
      RecentlyActiveAccountsCache.accounts.count.must_equal 1
    end
  end
end
