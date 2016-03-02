require 'test_helper'

class Reverification::MailerTest < ActiveSupport::TestCase
  let(:verified_account) { create(:account) }
  let(:unverified_account_sucess) { create(:unverified_account, :success) }

  describe 'send_first_notification' do
    it 'should send notification to unverified accounts only' do
      Reverification::Process.stubs(:ses_limit_reached?).returns(false)
      Account.expects(:reverification_not_initiated).returns([unverified_account_sucess])
      unverified_account_sucess.reverification_tracker.must_be_nil
      Reverification::Mailer.send_first_notification
      unverified_account_sucess.reverification_tracker.must_be :present?
      unverified_account_sucess.reverification_tracker.phase.must_equal 'initial'
      unverified_account_sucess.reverification_tracker.attempts.must_equal 1
    end
  end

  describe 'send_marked_for_spam_notification' do
    before do
      Reverification::Process.stubs(:ses_limit_reached?).returns(false)
      create(:reverification_tracker, account: unverified_account_sucess, sent_at: Time.now - 14.days)
    end

    #Note: No clue why Reverfication::Process.send results in argument error at this point; have to fix it.
    it 'should send marked for spam notifcation after 14 days' do
      Reverification::Mailer.send_marked_for_spam_notification
      unverified_account_sucess.reverification_tracker.phase.must_equal 'marked_for_spam'
      unverified_account_sucess.reverification_tracker.attempts.must_equal 1
    end

    it 'should not send marked for spam notifcation ahead 14 days' do
      unverified_account_sucess.reverification_tracker.update(sent_at: Time.now - 13.days)
      Reverification::Process.expects(:send).never
      Reverification::Mailer.send_marked_for_spam_notification
    end
  end

  describe 'run' do
    describe 'send_notifications' do
      it 'should send notifications to accounts' do
        Reverification::Process.stubs(:ses_limit_reached?).returns(false)
        Reverification::Mailer.expects(:send_final_notification)
        Reverification::Mailer.expects(:send_converted_to_spam_notification)
        Reverification::Mailer.expects(:send_marked_for_spam_notification)
        Reverification::Mailer.expects(:send_first_notification)
        Reverification::Mailer.send_notifications
      end

      it 'should not send notifications if ses limit is reached' do
        Reverification::Process.stubs(:ses_limit_reached?).returns(true)
        Reverification::Mailer.expects(:send_final_notification).never
        Reverification::Mailer.expects(:send_converted_to_spam_notification).never
        Reverification::Mailer.expects(:send_marked_for_spam_notification).never
        Reverification::Mailer.expects(:send_first_notification).never
        Reverification::Mailer.send_notifications
      end
    end

    # ================ Note: Double check these tests =============
    describe 'notifications' do
      it 'should send a final notification to the correct accounts' do
        create(:spam_rev_tracker, updated_at: DateTime.now.utc - 6.day)
        create(:marked_for_spam_rev_tracker)
        create(:initial_rev_tracker)
        Reverification::Process.expects(:send).once
        Reverification::Mailer.send_final_notification
      end

      it 'should send a converted to spam notification to the correct accounts' do
        create(:marked_for_spam_rev_tracker, updated_at: DateTime.now.utc - 1.day)
        create(:initial_rev_tracker)
        Reverification::Process.expects(:send).once
        Reverification::Mailer.send_converted_to_spam_notification
      end

      it 'should send a marked for spam notification to the correct accounts' do
        past = DateTime.now.utc - 14.day
        create(:initial_rev_tracker, created_at: past, updated_at: past)
        Reverification::Process.expects(:send).once
        Reverification::Mailer.send_marked_for_spam_notification
      end
    end
    # ==============================================================

    describe 'delete_unverified_spam_accounts' do
      it 'should retrieve the correct accounts for deletion' do
        create(:account)
        create(:invalid_final_warning_rev_tracker, updated_at: DateTime.now.utc + 1.day)
        valid = create(:final_warning_rev_tracker, updated_at: DateTime.now.utc + 1.day)
        assert_equal 4, Account.count  # 3 we created + Hamster
        Reverification::Mailer.delete_unverified_spam_accounts
        assert_equal 1, ReverificationTracker.count
        assert_equal 1, DeletedAccount.count 
      end

      it 'should delete accounts that have passed the cutoff for account renewal' do
        create(:final_warning_rev_tracker, updated_at: DateTime.now.utc + 1.day)
        Reverification::Mailer.delete_unverified_spam_accounts
        # Note: Anonymous coward and slave are the two accounts persisted.
        assert_equal 0, ReverificationTracker.count
        assert_equal 1, DeletedAccount.count
      end

      it 'should not delete accounts that are premature' do
        create(:final_warning_rev_tracker, updated_at: DateTime.now.utc - 1.day)
        Reverification::Mailer.delete_unverified_spam_accounts
        assert_equal 2, Account.count
        assert_equal 0, DeletedAccount.count
        assert_equal 1, ReverificationTracker.count 
      end
    end
  end
end
