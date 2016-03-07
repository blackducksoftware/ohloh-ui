require 'test_helper'

class ReverificationTrackerTest < ActiveSupport::TestCase
  let(:suc_acc_1) { create(:unverified_account, email: 'success1@simulator.amazonses.com') }
  let(:suc_acc_2) { create(:unverified_account, email: 'success2@simulator.amazonses.com') }
  let(:sbounce_acc_1) { create(:unverified_account, email: 'ooto1@simulator.amazonses.com') }

  describe 'cleanup' do
    it 'should destroy all reverification trackers if account verified' do
      verified = create(:reverification_tracker)
      unverified = create(:initial_rev_tracker)
      assert verified.account.access.mobile_or_oauth_verified?
      ReverificationTracker.cleanup
      assert_equal 1, ReverificationTracker.count
    end
  end

  describe 'expired_initial_phase_notifications' do
    before do
      create(:complained_initial_rev_tracker, sent_at: Time.now.utc - 14.days)
    end
    let(:initial_tracker1) { create(:success_initial_rev_tracker, sent_at: Time.now.utc - 15.days) }
    let(:initial_tracker2) { create(:success_initial_rev_tracker, account: suc_acc_1, sent_at: Time.now.utc - 14.days) }
    let(:initial_tracker3) { create(:success_initial_rev_tracker, account: suc_acc_2, sent_at: Time.now.utc - 13.days) }
    let(:soft_bounced_tracker1) { create(:initial_rev_tracker, :soft_bounced, attempts: 2, sent_at: Time.now.utc - 14.days) }

    it 'should return initial notifications tracker which are not verified within 2weeks/14 days' do
      exp_noti = ReverificationTracker.expired_initial_phase_notifications
      exp_noti.must_equal [ initial_tracker1, initial_tracker2 ]
      assert_equal ['initial'], exp_noti.map(&:phase).uniq
      assert_equal [true, true], exp_noti.map {|n| (Time.now - n.sent_at).to_i >= 14}
    end

    it 'should return initial notifications tracker which are successfully delivered to recipients' do
      exp_noti = ReverificationTracker.expired_initial_phase_notifications
      exp_noti.must_equal [ initial_tracker1, initial_tracker2 ] #Note: Here the lazy loading of ActiveRecord::Relation breaks the execution sequence cause of belonging methods not loaded into memory early.
      assert_equal [true, true], exp_noti.map(&:delivered?)
    end

    it 'should return initial notifications tracker which soft bounced 3 times' do
      soft_bounced_thrice_tracker2 = create(:initial_rev_tracker, :soft_bounced, account: sbounce_acc_1, attempts: 3, sent_at: Time.now.utc - 14.days)
      exp_noti = ReverificationTracker.expired_initial_phase_notifications
      exp_noti.must_include soft_bounced_thrice_tracker2
      assert_equal 3, soft_bounced_thrice_tracker2.attempts
      exp_noti.wont_include soft_bounced_tracker1
    end
  end

  describe 'expired_second_phase_notifications' do
    before do
      create(:marked_for_spam_rev_tracker, :complained, sent_at: Time.now.utc - 14.days)
    end
    let(:marked_spam_tracker1) { create(:marked_for_spam_rev_tracker, :delivered, sent_at: Time.now.utc - 15.days) }
    let(:marked_spam_tracker2) { create(:marked_for_spam_rev_tracker, :delivered, account: suc_acc_1, sent_at: Time.now.utc - 14.days) }
    let(:marked_spam_tracker3) { create(:marked_for_spam_rev_tracker, :delivered, account: suc_acc_2, sent_at: Time.now.utc - 13.days) }
    let(:soft_bounced_tracker1) { create(:marked_for_spam_rev_tracker, :soft_bounced, attempts: 2, sent_at: Time.now.utc - 14.days) }

    it 'should return marked for spam notifications tracker which are not verified within 2weeks/14 days' do
      exp_noti = ReverificationTracker.expired_second_phase_notifications
      exp_noti.must_equal [ marked_spam_tracker1, marked_spam_tracker2 ]
      assert_equal ['marked_for_spam'], exp_noti.map(&:phase).uniq
      assert_equal [true, true], exp_noti.map {|n| (Time.now - n.sent_at).to_i >= 14}
    end

    it 'should return marked for spam notifications tracker which are successfully delivered to recipients' do
      exp_noti = ReverificationTracker.expired_second_phase_notifications
      exp_noti.must_equal [ marked_spam_tracker1, marked_spam_tracker2 ] #Note: Here the lazy loading of ActiveRecord::Relation breaks the execution sequence cause of belonging methods not loaded into memory early.
      assert_equal [true, true], exp_noti.map(&:delivered?)
    end

    it 'should return marked for spam notifications tracker which soft bounced 3 times' do
      soft_bounced_thrice_tracker2 = create(:marked_for_spam_rev_tracker, :soft_bounced, account: sbounce_acc_1, attempts: 3, sent_at: Time.now.utc - 14.days)
      exp_noti = ReverificationTracker.expired_second_phase_notifications
      exp_noti.must_include soft_bounced_thrice_tracker2
      assert_equal 3, soft_bounced_thrice_tracker2.attempts
      exp_noti.wont_include soft_bounced_tracker1
    end
  end

  describe 'expired_third_phase_notifications' do
    before do
      create(:spam_rev_tracker, :complained, sent_at: Time.now.utc - 14.days)
    end
    let(:spam_tracker1) { create(:spam_rev_tracker, :delivered, sent_at: Time.now.utc - 15.days) }
    let(:spam_tracker2) { create(:spam_rev_tracker, :delivered, account: suc_acc_1, sent_at: Time.now.utc - 14.days) }
    let(:spam_tracker3) { create(:spam_rev_tracker, :delivered, account: suc_acc_2, sent_at: Time.now.utc - 13.days) }
    let(:soft_bounced_tracker1) { create(:spam_rev_tracker, :soft_bounced, attempts: 2, sent_at: Time.now.utc - 14.days) }

    it 'should return spammed notifications trackers which are not verified within 2weeks/14 days' do
      exp_noti = ReverificationTracker.expired_third_phase_notifications
      exp_noti.must_equal [ spam_tracker1, spam_tracker2 ]
      assert_equal ['spam'], exp_noti.map(&:phase).uniq
      assert_equal [true, true], exp_noti.map {|n| (Time.now - n.sent_at).to_i >= 14}
    end

    it 'should return spammed notifications trackers which are successfully delivered to recipients' do
      exp_noti = ReverificationTracker.expired_third_phase_notifications
      exp_noti.must_equal [ spam_tracker1, spam_tracker2 ] #Note: Here the lazy loading of ActiveRecord::Relation breaks the execution sequence cause of belonging methods not loaded into memory early.
      assert_equal [true, true], exp_noti.map(&:delivered?)
    end

    it 'should return spammed notifications tracker which soft bounced 3 times' do
      soft_bounced_thrice_tracker2 = create(:spam_rev_tracker, :soft_bounced, account: sbounce_acc_1, attempts: 3, sent_at: Time.now.utc - 14.days)
      exp_noti = ReverificationTracker.expired_third_phase_notifications
      exp_noti.must_include soft_bounced_thrice_tracker2
      assert_equal 3, soft_bounced_thrice_tracker2.attempts
      exp_noti.wont_include soft_bounced_tracker1
    end
  end

  describe 'expired_final_phase_notifications' do
    before do
      create(:final_warning_rev_tracker, :complained, sent_at: Time.now.utc - 14.days)
    end
    let(:final_warning_rev_tracker1) { create(:final_warning_rev_tracker, :delivered, sent_at: Time.now.utc - 15.days) }
    let(:final_warning_rev_tracker2) { create(:final_warning_rev_tracker, :delivered, account: suc_acc_1, sent_at: Time.now.utc - 14.days) }
    let(:final_warning_rev_tracker3) { create(:final_warning_rev_tracker, :delivered, account: suc_acc_2, sent_at: Time.now.utc - 13.days) }
    let(:soft_bounced_tracker1) { create(:final_warning_rev_tracker, :soft_bounced, attempts: 2, sent_at: Time.now.utc - 14.days) }

    it 'should return final warning notifications trackers which are not verified within 2weeks/14 days' do
      exp_noti = ReverificationTracker.expired_final_phase_notifications
      exp_noti.must_equal [ final_warning_rev_tracker1, final_warning_rev_tracker2 ]
      assert_equal ['final_warning'], exp_noti.map(&:phase).uniq
      assert_equal [true, true], exp_noti.map {|n| (Time.now - n.sent_at).to_i >= 14}
    end

    it 'should return final warning notifications trackers which are successfully delivered to recipients' do
      exp_noti = ReverificationTracker.expired_final_phase_notifications
      exp_noti.must_equal [ final_warning_rev_tracker1, final_warning_rev_tracker2 ] #Note: Here the lazy loading of ActiveRecord::Relation breaks the execution sequence cause of belonging methods not loaded into memory early.
      assert_equal [true, true], exp_noti.map(&:delivered?)
    end

    it 'should return final warning notifications tracker which soft bounced 3 times' do
      soft_bounced_thrice_tracker2 = create(:final_warning_rev_tracker, :soft_bounced, account: sbounce_acc_1, attempts: 3, sent_at: Time.now.utc - 14.days)
      exp_noti = ReverificationTracker.expired_final_phase_notifications
      exp_noti.must_include soft_bounced_thrice_tracker2
      assert_equal 3, soft_bounced_thrice_tracker2.attempts
      exp_noti.wont_include soft_bounced_tracker1
    end
  end
end
