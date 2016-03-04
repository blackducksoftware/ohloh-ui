require 'test_helper'

class Reverification::MailerTest < ActiveSupport::TestCase
  let(:verified_account) { create(:account) }
  let(:unverified_account_sucess) { create(:unverified_account, :success) }

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
  end

  describe 'resend_soft_bounced_notifications' do
    it 'should send the first reverification to soft_bounced initial phase accounts' do
      account = create(:soft_bounce_initial_rev_tracker, sent_at: Date.today - 1.day).account
      template = Reverification::Template.first_reverification_notice(account.email)
      Reverification::Process.expects(:send).with(template, account, 0)
      Reverification::Mailer.resend_soft_bounced_notifications
    end

    # First attempt resend
    it 'should update the increment account of the rev_tracker by one' do
      rev_tracker = create(:soft_bounce_initial_rev_tracker, sent_at: Date.today - 1.day)
      Reverification::Mailer.resend_soft_bounced_notifications
      rev_tracker.reload
      assert_equal 2, rev_tracker.attempts
    end

    # Second attempt resend
    it 'should update the increment account of the rev_tracker by one' do
      rev_tracker = create(:soft_bounce_initial_rev_tracker, attempts: 2, sent_at: Date.today - 1.day)
      Reverification::Mailer.resend_soft_bounced_notifications
      rev_tracker.reload
      assert_equal 3, rev_tracker.attempts
    end

    # Third attempt resend
    it "it should send the account's rev_tracker to be delivered on the third attempt" do
      rev_tracker = create(:soft_bounce_initial_rev_tracker, attempts: 3, sent_at: Date.today - 1.day)
      Reverification::Mailer.resend_soft_bounced_notifications
      rev_tracker.reload
      assert rev_tracker.delivered?
      # Note: I wasn't able to convert the time field to match exactly. 
      # Although the time is right.
      assert_equal rev_tracker.sent_at, Date.today
      assert_equal 1, rev_tracker.attempts
    end
  end

  describe 'send_marked_for_spam_notification' do
    before do
      Reverification::Process.stubs(:ses_limit_reached?).returns(false)
      create(:reverification_tracker, account: unverified_account_sucess, sent_at: Time.now - 14.days)
    end

    #Note: No clue why Reverfication::Mailer.send results in argument error at this point; have to fix it.
    it 'should send marked for spam notification after 14 days' do
      Reverification::Mailer.send_marked_for_spam_notification
      unverified_account_sucess.reverification_tracker.phase.must_equal 'marked_for_spam'
      unverified_account_sucess.reverification_tracker.attempts.must_equal 1
    end

    it 'should not send marked for spam notification ahead 14 days' do
      unverified_account_sucess.reverification_tracker.update(sent_at: Time.now - 13.days)
      Reverification::Process.expects(:send).never
      Reverification::Mailer.send_marked_for_spam_notification
    end
  end

  describe 'delete_unverified_spam_accounts' do
    it 'should retrieve the correct accounts for deletion' do
      create(:account) #invalid
      create(:invalid_final_warning_rev_tracker, sent_at: Date.today - 3.weeks) #invalid
      create(:final_warning_rev_tracker, sent_at: Date.today - 2.weeks) #correct
      create(:final_warning_rev_tracker, sent_at: Date.today - 1.weeks) #correct
      assert_equal 3, ReverificationTracker.count
      assert_equal 5, Account.count  # 3 we created + Hamster
      ReverificationTracker.delete_unverified_spam_accounts
      assert_equal 1, ReverificationTracker.count
      assert_equal 2, DeletedAccount.count 
    end
  end
end
