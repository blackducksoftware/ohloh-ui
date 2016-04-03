require 'test_helper'

class ReverificationTrackerTest < ActiveSupport::TestCase
  let(:suc_acc_1) { create(:unverified_account, email: 'success1@simulator.amazonses.com') }
  let(:suc_acc_2) { create(:unverified_account, email: 'success2@simulator.amazonses.com') }
  let(:sbounce_acc_1) { create(:unverified_account, email: 'ooto1@simulator.amazonses.com') }

  describe 'template_hash' do
    before do
      @rev_track_one = create(:initial_rev_tracker)
      @rev_track_two = create(:marked_for_spam_rev_tracker)
      @rev_track_three = create(:spam_rev_tracker)
      @rev_track_four = create(:final_warning_rev_tracker)
    end

    it 'should expect first_reverification_notice when initial' do
      Reverification::Template.expects(:send).with(:first_reverification_notice, @rev_track_one.account.email)
      @rev_track_one.template_hash
    end

    it 'should expect marked_for_spam when marked_for_spam?' do
      Reverification::Template.expects(:send).with(:marked_for_spam_notice, @rev_track_two.account.email)
      @rev_track_two.template_hash
    end

    it 'should expect account_is_spam when spam?' do
      Reverification::Template.expects(:send).with(:account_is_spam_notice, @rev_track_three.account.email)
      @rev_track_three.template_hash
    end

    it 'should expect final_warning_notice when final_warning?' do
      Reverification::Template.expects(:send).with(:final_warning_notice, @rev_track_four.account.email)
      @rev_track_four.template_hash
    end
  end

  describe 'expired_initial_phase_notifications' do
    before do
      create(:complained_initial_rev_tracker, sent_at: Time.now.utc - 14.days)
    end
    now = Time.now.utc
    let(:initial_tracker1) { create(:success_initial_rev_tracker, sent_at: now - 15.days) }
    let(:initial_tracker2) { create(:success_initial_rev_tracker, account: suc_acc_1, sent_at: now - 14.days) }
    let(:initial_tracker3) { create(:success_initial_rev_tracker, account: suc_acc_2, sent_at: now - 13.days) }
    let(:soft_bounced_tracker1) { create(:initial_rev_tracker, :soft_bounced, attempts: 2, sent_at: now - 14.days) }

    it 'should return initial notifications tracker which are not verified within 2weeks/14 days' do
      exp_noti = ReverificationTracker.expired_initial_phase_notifications
      exp_noti.must_equal [initial_tracker1, initial_tracker2]
      assert_equal ['initial'], exp_noti.map(&:phase).uniq
      assert_equal [true, true], exp_noti.map { |n| (Time.now.utc - n.sent_at).to_i >= 14 }
    end

    it 'should return initial notifications tracker which are successfully delivered to recipients' do
      exp_noti = ReverificationTracker.expired_initial_phase_notifications
      # Note: Here the lazy loading of ActiveRecord::Relation breaks the
      # execution sequence cause of belonging methods not loaded into memory early.
      exp_noti.must_equal [initial_tracker1, initial_tracker2]
      assert_equal [true, true], exp_noti.map(&:delivered?)
    end

    it 'should return initial notifications tracker which soft bounced 3 times' do
      soft_bounced_thrice_tracker2 = create(:initial_rev_tracker,
                                            :soft_bounced,
                                            account: sbounce_acc_1,
                                            attempts: 3,
                                            sent_at: Time.now.utc - 14.days)
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
    let(:marked_spam_tracker1) do
      create(:marked_for_spam_rev_tracker, :delivered, sent_at: Time.now.utc - 15.days)
    end
    let(:marked_spam_tracker2) do
      create(:marked_for_spam_rev_tracker, :delivered, account: suc_acc_1, sent_at: Time.now.utc - 14.days)
    end
    let(:marked_spam_tracker3) do
      create(:marked_for_spam_rev_tracker, :delivered, account: suc_acc_2, sent_at: Time.now.utc - 13.days)
    end
    let(:soft_bounced_tracker1) do
      create(:marked_for_spam_rev_tracker, :soft_bounced, attempts: 2, sent_at: Time.now.utc - 14.days)
    end

    it 'should return marked for spam notifications tracker which are not verified within 2weeks/14 days' do
      exp_noti = ReverificationTracker.expired_second_phase_notifications
      exp_noti.must_equal [marked_spam_tracker1, marked_spam_tracker2]
      assert_equal ['marked_for_spam'], exp_noti.map(&:phase).uniq
      assert_equal [true, true], exp_noti.map { |n| (Time.now.utc - n.sent_at).to_i >= 14 }
    end

    it 'should return marked for spam notifications tracker which are successfully delivered to recipients' do
      exp_noti = ReverificationTracker.expired_second_phase_notifications
      # Note: Here the lazy loading of ActiveRecord::Relation breaks the execution
      # sequence cause of belonging methods not loaded into memory early.
      exp_noti.must_equal [marked_spam_tracker1, marked_spam_tracker2]
      assert_equal [true, true], exp_noti.map(&:delivered?)
    end

    it 'should return marked for spam notifications tracker which soft bounced 3 times' do
      soft_bounced_thrice_tracker2 = create(:marked_for_spam_rev_tracker,
                                            :soft_bounced,
                                            account: sbounce_acc_1,
                                            attempts: 3,
                                            sent_at: Time.now.utc - 14.days)
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
    let(:spam_tracker1) do
      create(:spam_rev_tracker, :delivered, sent_at: Time.now.utc - 15.days)
    end
    let(:spam_tracker2) do
      create(:spam_rev_tracker, :delivered, account: suc_acc_1, sent_at: Time.now.utc - 14.days)
    end
    let(:spam_tracker3) do
      create(:spam_rev_tracker, :delivered, account: suc_acc_2, sent_at: Time.now.utc - 13.days)
    end
    let(:soft_bounced_tracker1) do
      create(:spam_rev_tracker, :soft_bounced, attempts: 2, sent_at: Time.now.utc - 14.days)
    end

    it 'should return spammed notifications trackers which are not verified within 2weeks/14 days' do
      exp_noti = ReverificationTracker.expired_third_phase_notifications
      exp_noti.must_equal [spam_tracker1, spam_tracker2]
      assert_equal ['spam'], exp_noti.map(&:phase).uniq
      assert_equal [true, true], exp_noti.map { |n| (Time.now.utc - n.sent_at).to_i >= 14 }
    end

    it 'should return spammed notifications trackers which are successfully delivered to recipients' do
      exp_noti = ReverificationTracker.expired_third_phase_notifications
      # Note: Here the lazy loading of ActiveRecord::Relation breaks the execution
      # sequence cause of belonging methods not loaded into memory early.
      exp_noti.must_equal [spam_tracker1, spam_tracker2]
      assert_equal [true, true], exp_noti.map(&:delivered?)
    end

    it 'should return spammed notifications tracker which soft bounced 3 times' do
      soft_bounced_thrice_tracker2 = create(:spam_rev_tracker,
                                            :soft_bounced,
                                            account: sbounce_acc_1,
                                            attempts: 3,
                                            sent_at: Time.now.utc - 14.days)
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
    let(:final_warning_rev_tracker1) do
      create(:final_warning_rev_tracker, :delivered, sent_at: Time.now.utc - 15.days)
    end
    let(:final_warning_rev_tracker2) do
      create(:final_warning_rev_tracker, :delivered, account: suc_acc_1, sent_at: Time.now.utc - 14.days)
    end
    let(:final_warning_rev_tracker3) do
      create(:final_warning_rev_tracker, :delivered, account: suc_acc_2, sent_at: Time.now.utc - 13.days)
    end
    let(:soft_bounced_tracker1) do
      create(:final_warning_rev_tracker, :soft_bounced, attempts: 2, sent_at: Time.now.utc - 14.days)
    end

    it 'should return final warning notifications trackers which are not verified within 2weeks/14 days' do
      exp_noti = ReverificationTracker.expired_final_phase_notifications
      exp_noti.must_equal [final_warning_rev_tracker1, final_warning_rev_tracker2]
      assert_equal ['final_warning'], exp_noti.map(&:phase).uniq
      assert_equal [true, true], exp_noti.map { |n| (Time.now.utc - n.sent_at).to_i >= 14 }
    end

    it 'should return final warning notifications trackers which are successfully delivered to recipients' do
      exp_noti = ReverificationTracker.expired_final_phase_notifications
      # Note: Here the lazy loading of ActiveRecord::Relation breaks the execution
      # sequence cause of belonging methods not loaded into memory early.
      exp_noti.must_equal [final_warning_rev_tracker1, final_warning_rev_tracker2]
      assert_equal [true, true], exp_noti.map(&:delivered?)
    end

    it 'should return final warning notifications tracker which soft bounced 3 times' do
      soft_bounced_thrice_tracker2 = create(:final_warning_rev_tracker,
                                            :soft_bounced,
                                            account: sbounce_acc_1,
                                            attempts: 3,
                                            sent_at: Time.now.utc - 14.days)
      exp_noti = ReverificationTracker.expired_final_phase_notifications
      exp_noti.must_include soft_bounced_thrice_tracker2
      assert_equal 3, soft_bounced_thrice_tracker2.attempts
      exp_noti.wont_include soft_bounced_tracker1
    end
  end

  describe 'destroy_account' do
    before do
      @account = create(:account)
    end

    it 'should destroy an account by email' do
      ReverificationTracker.destroy_account(@account.email)
      assert_equal 1, DeletedAccount.count
    end

    it "should not destroy an account if the account doesn't exist" do
      Account.stubs(:find_by_email).returns(nil)
      Account.any_instance.expects(:destroy).never
      ReverificationTracker.destroy_account(@account.email)
    end

    it 'should convert the account as spam before delete it' do
      Account.any_instance.stubs(:destroy).returns(nil)
      ReverificationTracker.destroy_account(@account.email)
      assert @account.reload.access.spam?
    end
  end

  describe 'delete_expired_accounts' do
    it 'should retrieve the correct accounts for deletion' do
      create(:final_warning_rev_tracker, :delivered, attempts: 3, sent_at: Time.now.utc - 15.days)
      create(:final_warning_rev_tracker, :soft_bounced, sent_at: Time.now.utc - 15.days)
      create(:final_warning_rev_tracker, :delivered, sent_at: Time.now.utc - 15.days)
      create(:final_warning_rev_tracker, :delivered, sent_at: Time.now.utc - 14.days)
      create(:final_warning_rev_tracker, :delivered, sent_at: Time.now.utc - 13.days)
      ReverificationTracker.delete_expired_accounts
      assert_equal 2, ReverificationTracker.count
      assert_equal 3, DeletedAccount.count
    end
  end

  describe 'remove_reverification_trackers_for_verifed_accounts' do
    it 'should destroy all reverification trackers if account verified' do
      verified = create(:reverification_tracker)
      unverified = create(:initial_rev_tracker)
      assert verified.account.access.mobile_or_oauth_verified?
      assert_not unverified.account.access.mobile_or_oauth_verified?
      ReverificationTracker.remove_reverification_trackers_for_verifed_accounts
      assert_equal 1, ReverificationTracker.count
    end
  end
end
