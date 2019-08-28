# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/reverification'

class ReverificationTrackerTest < ActiveSupport::TestCase
  NOTIFICATION1_DUE_DAYS = 21
  NOTIFICATION2_DUE_DAYS = 140
  NOTIFICATION3_DUE_DAYS = 28
  NOTIFICATION4_DUE_DAYS = 14

  let(:suc_acc_1) { create(:unverified_account, email: 'success1@simulator.amazonses.com') }
  let(:suc_acc_2) { create(:unverified_account, email: 'success2@simulator.amazonses.com') }
  let(:sbounce_acc_1) { create(:unverified_account, email: 'ooto1@simulator.amazonses.com') }

  describe 'template_hash' do
    before do
      @rev_track_one = create(:initial_rev_tracker)
      @rev_track_two = create(:marked_for_disable_rev_tracker)
      @rev_track_three = create(:disable_rev_tracker)
      @rev_track_four = create(:final_warning_rev_tracker)
    end

    it 'should expect first_reverification_notice when initial' do
      Reverification::Template.expects(:send).with(:first_reverification_notice, @rev_track_one.account.email)
      @rev_track_one.template_hash
    end

    it 'should expect marked_for_disable when marked_for_disable?' do
      Reverification::Template.expects(:send).with(:marked_for_disable_notice, @rev_track_two.account.email)
      @rev_track_two.template_hash
    end

    it 'should expect account_is_disable when disable?' do
      Reverification::Template.expects(:send).with(:account_is_disabled_notice, @rev_track_three.account.email)
      @rev_track_three.template_hash
    end

    it 'should expect final_warning_notice when final_warning?' do
      Reverification::Template.expects(:send).with(:final_warning_notice, @rev_track_four.account.email)
      @rev_track_four.template_hash
    end
  end

  describe 'expired_initial_phase_notifications' do
    now = Time.now.utc
    let(:initial_tracker1) { create(:success_initial_rev_tracker, account: suc_acc_1, sent_at: now - 22.days) }
    let(:initial_tracker2) { create(:success_initial_rev_tracker, sent_at: now - NOTIFICATION1_DUE_DAYS.days) }
    let(:initial_tracker3) { create(:success_initial_rev_tracker, account: suc_acc_2, sent_at: now - 20.days) }
    let(:soft_bounced_tracker1) { create(:initial_rev_tracker, :soft_bounced, attempts: 2, sent_at: now - 20.days) }

    it 'should return initial notifications tracker which are not verified within 21 days' do
      exp_noti = ReverificationTracker.expired_initial_phase_notifications
      exp_noti.must_equal [initial_tracker1, initial_tracker2]
      assert_equal ['initial'], exp_noti.map(&:phase).uniq
      assert_equal [true, true], (exp_noti.map { |n| (Time.now.utc - n.sent_at).to_i >= NOTIFICATION1_DUE_DAYS })
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
                                            sent_at: Time.now.utc - NOTIFICATION1_DUE_DAYS.days)
      exp_noti = ReverificationTracker.expired_initial_phase_notifications
      exp_noti.must_include soft_bounced_thrice_tracker2
      assert_equal 3, soft_bounced_thrice_tracker2.attempts
      exp_noti.wont_include soft_bounced_tracker1
    end
  end

  describe 'expired_second_phase_notifications' do
    let(:marked_disable_tracker1) do
      create(:marked_for_disable_rev_tracker, :delivered, sent_at: Time.now.utc - NOTIFICATION2_DUE_DAYS.days)
    end
    let(:marked_disable_tracker2) do
      create(:marked_for_disable_rev_tracker, :delivered, account: suc_acc_1, sent_at: Time.now.utc - 141.days)
    end
    let(:marked_disable_tracker3) do
      create(:marked_for_disable_rev_tracker, :delivered, account: suc_acc_2, sent_at: Time.now.utc - 139.days)
    end
    let(:soft_bounced_tracker1) do
      create(:marked_for_disable_rev_tracker, :soft_bounced, attempts: 2, sent_at: Time.now.utc - 14.days)
    end

    it 'should return marked for disable notifications tracker which are not verified within 140 days' do
      exp_noti = ReverificationTracker.expired_second_phase_notifications
      exp_noti.must_equal [marked_disable_tracker1, marked_disable_tracker2]
      assert_equal ['marked_for_disable'], exp_noti.map(&:phase).uniq
      assert_equal [true, true], (exp_noti.map { |n| (Time.now.utc - n.sent_at).to_i >= NOTIFICATION2_DUE_DAYS })
    end

    it 'should return marked for disable notifications tracker which are successfully delivered to recipients' do
      exp_noti = ReverificationTracker.expired_second_phase_notifications
      # Note: Here the lazy loading of ActiveRecord::Relation breaks the execution
      # sequence cause of belonging methods not loaded into memory early.
      exp_noti.must_equal [marked_disable_tracker1, marked_disable_tracker2]
      assert_equal [true, true], exp_noti.map(&:delivered?)
    end

    it 'should return marked for disable notifications tracker which soft bounced 3 times' do
      soft_bounced_thrice_tracker2 = create(:marked_for_disable_rev_tracker,
                                            :soft_bounced,
                                            account: sbounce_acc_1,
                                            attempts: 3,
                                            sent_at: Time.now.utc - NOTIFICATION2_DUE_DAYS.days)
      exp_noti = ReverificationTracker.expired_second_phase_notifications
      exp_noti.must_include soft_bounced_thrice_tracker2
      assert_equal 3, soft_bounced_thrice_tracker2.attempts
      exp_noti.wont_include soft_bounced_tracker1
    end
  end

  describe 'expired_third_phase_notifications' do
    let(:disable_tracker1) do
      create(:disable_rev_tracker, :delivered, sent_at: Time.now.utc - NOTIFICATION3_DUE_DAYS.days)
    end
    let(:disable_tracker2) do
      create(:disable_rev_tracker, :delivered, account: suc_acc_1, sent_at: Time.now.utc - 29.days)
    end
    let(:disable_tracker3) do
      create(:disable_rev_tracker, :delivered, account: suc_acc_2, sent_at: Time.now.utc - 27.days)
    end
    let(:soft_bounced_tracker1) do
      create(:disable_rev_tracker, :soft_bounced, attempts: 2, sent_at: Time.now.utc - 14.days)
    end

    it 'should return disabled notifications trackers which are not verified within 28 days' do
      exp_noti = ReverificationTracker.expired_third_phase_notifications
      exp_noti.must_equal [disable_tracker1, disable_tracker2]
      assert_equal ['disabled'], exp_noti.map(&:phase).uniq
      assert_equal [true, true], (exp_noti.map { |n| (Time.now.utc - n.sent_at).to_i >= NOTIFICATION3_DUE_DAYS })
    end

    it 'should return disablemed notifications trackers which are successfully delivered to recipients' do
      exp_noti = ReverificationTracker.expired_third_phase_notifications
      # Note: Here the lazy loading of ActiveRecord::Relation breaks the execution
      # sequence cause of belonging methods not loaded into memory early.
      exp_noti.must_equal [disable_tracker1, disable_tracker2]
      assert_equal [true, true], exp_noti.map(&:delivered?)
    end

    it 'should return disablemed notifications tracker which soft bounced 3 times' do
      soft_bounced_thrice_tracker2 = create(:disable_rev_tracker,
                                            :soft_bounced,
                                            account: sbounce_acc_1,
                                            attempts: 3,
                                            sent_at: Time.now.utc - NOTIFICATION3_DUE_DAYS.days)
      exp_noti = ReverificationTracker.expired_third_phase_notifications
      exp_noti.must_include soft_bounced_thrice_tracker2
      assert_equal 3, soft_bounced_thrice_tracker2.attempts
      exp_noti.wont_include soft_bounced_tracker1
    end
  end

  describe 'expired_final_phase_notifications' do
    let(:final_warning_rev_tracker1) do
      create(:final_warning_rev_tracker, :delivered, sent_at: Time.now.utc - NOTIFICATION4_DUE_DAYS.days)
    end
    let(:final_warning_rev_tracker2) do
      create(:final_warning_rev_tracker, :delivered, account: suc_acc_1, sent_at: Time.now.utc - 15.days)
    end
    let(:final_warning_rev_tracker3) do
      create(:final_warning_rev_tracker, :delivered, account: suc_acc_2, sent_at: Time.now.utc - 13.days)
    end
    let(:soft_bounced_tracker1) do
      create(:final_warning_rev_tracker, :soft_bounced, attempts: 2, sent_at: Time.now.utc - 13.days)
    end

    it 'should return final warning notifications trackers which are not verified within 14 days' do
      exp_noti = ReverificationTracker.expired_final_phase_notifications
      exp_noti.must_equal [final_warning_rev_tracker1, final_warning_rev_tracker2]
      assert_equal ['final_warning'], exp_noti.map(&:phase).uniq
      assert_equal [true, true], (exp_noti.map { |n| (Time.now.utc - n.sent_at).to_i >= NOTIFICATION4_DUE_DAYS })
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
                                            sent_at: Time.now.utc - NOTIFICATION4_DUE_DAYS.days)
      exp_noti = ReverificationTracker.expired_final_phase_notifications
      exp_noti.must_include soft_bounced_thrice_tracker2
      assert_equal 3, soft_bounced_thrice_tracker2.attempts
      exp_noti.wont_include soft_bounced_tracker1
    end
  end

  describe 'cleanup' do
    it 'should invoke cleanup methods' do
      create(:reverification_tracker)
      rt_needs_to_be_disabled = create(:rev_tracker_needs_disabling)
      create(:final_warning_rev_tracker, :delivered, attempts: 3, sent_at: Time.now.utc - 60.days)
      orphaned_rt = create(:reverification_tracker)
      orphaned_rt.update_attribute(:account_id, 1010)
      ReverificationTracker.cleanup
      ReverificationTracker.count.must_equal 1
      rt_needs_to_be_disabled.reload.account.access.level.must_equal(-10)
    end
  end

  describe 'destroy_account' do
    before do
      @account = create(:account)
    end

    it 'should destroy an account by email' do
      assert_difference('DeletedAccount.count', +1) do
        ReverificationTracker.destroy_account(@account.email)
      end
    end

    it 'should not destroy an account if the account doesnt exist' do
      Account.stubs(:find_by).returns(nil)
      Account.any_instance.expects(:destroy).never
      ReverificationTracker.destroy_account(@account.email)
    end
  end

  describe 'delete_expired_accounts' do
    it 'should retrieve the correct accounts for deletion' do
      create(:final_warning_rev_tracker, :delivered,
             sent_at: Time.now.utc - NOTIFICATION4_DUE_DAYS.days)
      create(:final_warning_rev_tracker, :delivered,
             sent_at: Time.now.utc - (NOTIFICATION4_DUE_DAYS.days + 1.day))
      create(:final_warning_rev_tracker,
             :soft_bounced,
             attempts: 3,
             sent_at: Time.now.utc - NOTIFICATION4_DUE_DAYS.days)
      create(:final_warning_rev_tracker, :delivered, sent_at: Time.now.utc - 12.days)
      ReverificationTracker.delete_expired_accounts
      assert_equal 1, ReverificationTracker.count
      assert_equal 3, DeletedAccount.count
    end

    it 'should just delete the tracker if its account does not exist' do
      rev_tracker = create(:final_warning_rev_tracker,
                           :delivered,
                           attempts: 3,
                           sent_at: Time.now.utc - NOTIFICATION4_DUE_DAYS.days)
      rev_tracker.update_attribute(:account_id, 1010)
      Account::Access.any_instance.expects(:disable!).never
      Account.any_instance.expects(:destroy).never
      ReverificationTracker.any_instance.expects(:destroy)
      ReverificationTracker.delete_expired_accounts
    end
  end

  describe 'disable accounts' do
    it 'should disable an account' do
      account = create(:reverification_tracker, phase: 2).account
      ReverificationTracker.disable_accounts
      account.reload.access.level.must_equal(-10)
    end

    it 'should not try to disable an account that is already disabled' do
      account = create(:reverification_tracker, phase: 2).account
      account.update(level: -10)
      account.reload.access.level.must_equal(-10)
      ReverificationTracker.disable_accounts
      Account.any_instance.expects(:update_attributes!).never
    end
  end

  describe 'remove_reverification_trackers_for_verified_accounts' do
    it 'should destroy all reverification trackers if account verified' do
      verified = create(:reverification_tracker)
      unverified = create(:initial_rev_tracker)
      assert verified.account.access.mobile_or_oauth_verified?
      assert_not unverified.account.access.mobile_or_oauth_verified?
      ReverificationTracker.remove_reverification_trackers_for_verified_accounts
      assert_equal 1, ReverificationTracker.count
    end

    it 'should skip to the next rev_tracker for deletion if its account does not exist.' do
      rev_tracker = create(:reverification_tracker)
      rev_tracker.update_attribute(:account_id, 1010)
      assert_not rev_tracker.account
      ReverificationTracker.any_instance.expects(:destroy).never
      ReverificationTracker.remove_reverification_trackers_for_verified_accounts
    end
  end

  describe 'remove_orphans' do
    it 'should delete reverification tracker if its account does not exist' do
      rev_tracker = create(:reverification_tracker)
      rev_tracker.update_attribute(:account_id, 1010)
      assert_not rev_tracker.account
      ReverificationTracker.any_instance.expects(:destroy)
      ReverificationTracker.remove_orphans
    end

    it 'should not delete reverification tracker if its account exist' do
      rev_tracker = create(:reverification_tracker)
      assert rev_tracker.account
      ReverificationTracker.any_instance.expects(:destroy).never
      ReverificationTracker.remove_orphans
    end
  end

  describe 'update_reverification' do
    before do
      @rev_tracker = create(:reverification_tracker)
    end

    it 'should increment attempts when phase equals the phase value' do
      ReverificationTracker.update_tracker(@rev_tracker, 0, MOCK::AWS::SimpleEmailService.response)
      assert_equal 2, @rev_tracker.attempts
      assert_equal MOCK::AWS::SimpleEmailService.response[:message_id], @rev_tracker.message_id
      assert_equal 'pending', @rev_tracker.status
      assert_equal 'initial', @rev_tracker.phase
      assert_equal @rev_tracker.sent_at.to_date, Time.now.utc.to_date
    end

    it 'should reset attempts to 1 when phase does not match phase value' do
      ReverificationTracker.update_tracker(@rev_tracker, 1, MOCK::AWS::SimpleEmailService.response)
      assert_equal 1, @rev_tracker.attempts
      assert_equal MOCK::AWS::SimpleEmailService.response[:message_id], @rev_tracker.message_id
      assert_equal 'pending', @rev_tracker.status
      assert_equal 'marked_for_disable', @rev_tracker.phase
      assert_equal @rev_tracker.sent_at.to_date, Time.now.utc.to_date
    end
  end
end
