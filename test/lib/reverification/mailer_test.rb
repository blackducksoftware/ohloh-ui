require 'test_helper'

class Reverification::MailerTest < ActiveSupport::TestCase
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

      it 'should send a first notification to the correct accounts' do
        create(:unverified_account)
        Reverification::Process.expects(:send).once
        Reverification::Mailer.send_first_notification
      end

      it 'should create a rev_tracker when a first notification is sent' do
        create(:unverified_account)
        Reverification::Process.expects(:send).once
        # This test is breaking because of the blank response from ses.send_email
        Reverification::Mailer.stubs(:send_first_notification).yields(aws_response_message_id)
        assert_equal 1, ReverificationTracker.count
        assert ReverificationTracker.first.initial?
        assert ReverificationTracker.first.pending?
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
