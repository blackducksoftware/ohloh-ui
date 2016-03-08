require 'test_helper'

class Reverification::MailerTest < ActiveSupport::TestCase
  before do
    AWS::SimpleEmailService.any_instance.stubs(:send_email).returns(ses_send_mail_response)
    Reverification::Process.stubs(:ses_limit_reached?).returns(false)
  end
  let(:verified_account) { create(:account) }
  let(:unverified_account_sucess) { create(:unverified_account, :success) }

  describe 'constants' do
    it 'should have beeen defined' do
      assert_equal 3, Reverification::Mailer::MAX_ATTEMPTS
      assert_equal 14, Reverification::Mailer::NOTIFICATION1_DUE_DAYS
      assert_equal 14, Reverification::Mailer::NOTIFICATION2_DUE_DAYS
      assert_equal 14, Reverification::Mailer::NOTIFICATION3_DUE_DAYS
      assert_equal 14, Reverification::Mailer::NOTIFICATION4_DUE_DAYS
      assert_equal 'info@openhub.net', Reverification::Mailer::FROM
    end
  end

  describe 'ses quota limit' do
    before do
      Reverification::Process.expects(:ses_limit_reached?).returns(true)
    end

    it 'should not send notifications if ses limit is reached' do
      Reverification::Mailer.expects(:send_final_notification).never
      Reverification::Mailer.expects(:send_converted_to_spam_notification).never
      Reverification::Mailer.expects(:send_marked_for_spam_notification).never
      Reverification::Mailer.expects(:send_first_notification).never
      Reverification::Mailer.send_notifications
    end

    it 'should not send notifications if ses limit is reached' do
      Reverification::Process.expects(:send_email).never
      Reverification::Mailer.send_first_notification
    end

    it 'should not send notifications if ses limit is reached' do
      Reverification::Process.expects(:send_email).never
      Reverification::Mailer.send_marked_for_spam_notification
    end 

    it 'should not send notifications if ses limit is reached' do
      Reverification::Process.expects(:send_email).never
      Reverification::Mailer.send_converted_to_spam_notification
    end 

    it 'should not send notifications if ses limit is reached' do
      Reverification::Process.expects(:send_email).never
      Reverification::Mailer.send_final_notification
    end 
  end

  describe 'send_notifications' do
    it 'should send notifications to accounts' do
      Reverification::Mailer.expects(:send_final_notification)
      Reverification::Mailer.expects(:send_converted_to_spam_notification)
      Reverification::Mailer.expects(:send_marked_for_spam_notification)
      Reverification::Mailer.expects(:send_first_notification)
      Reverification::Mailer.send_notifications
    end
  end

  describe 'send_first_notification' do
    it 'should send notification to unverified accounts only' do
      Account.expects(:reverification_not_initiated).returns([unverified_account_sucess])
      Reverification::Template.expects(:first_reverification_notice)
      unverified_account_sucess.reverification_tracker.must_be_nil
      Reverification::Mailer.send_first_notification
      unverified_account_sucess.reverification_tracker.must_be :present?
      unverified_account_sucess.reverification_tracker.phase.must_equal 'initial'
      unverified_account_sucess.reverification_tracker.attempts.must_equal 1
      unverified_account_sucess.reverification_tracker.sent_at.to_date.must_equal Date.today
    end
  end

  describe 'send_marked_for_spam_notification' do
    before do
      @rev_tracker = create(:success_initial_rev_tracker, account: unverified_account_sucess, sent_at: Time.now.utc - Reverification::Mailer::NOTIFICATION1_DUE_DAYS.days)
      ReverificationTracker.expects(:expired_initial_phase_notifications).returns [@rev_tracker]
    end

    it 'should send correct email template' do
      Reverification::Template.expects(:marked_for_spam_notice)
      Reverification::Mailer.send_marked_for_spam_notification
    end

    it 'should change the phase to marked_for_spam' do
      Reverification::Mailer.send_marked_for_spam_notification
      @rev_tracker.phase.must_equal 'marked_for_spam'
    end

    it 'should reset the status to pending' do
      Reverification::Mailer.send_marked_for_spam_notification
      @rev_tracker.status.must_equal 'pending'
    end

    it 'should reset the attempts to 1' do
      Reverification::Mailer.send_marked_for_spam_notification
      @rev_tracker.attempts.must_equal 1
    end

    it 'should update the sent_at time' do
      Reverification::Mailer.send_marked_for_spam_notification
      @rev_tracker.sent_at.to_date.must_equal Date.today
    end
  end

  describe 'send_converted_to_spam_notification' do
    before do
      @rev_tracker = create(:marked_for_spam_rev_tracker, :delivered, account: unverified_account_sucess, sent_at: Time.now.utc - Reverification::Mailer::NOTIFICATION2_DUE_DAYS.days)
      ReverificationTracker.expects(:expired_second_phase_notifications).returns [@rev_tracker]
    end

    it 'should send correct email template' do
      Reverification::Template.expects(:account_is_spam_notice)
      Reverification::Mailer.send_converted_to_spam_notification
    end

    it 'should change the phase to spam' do
      Reverification::Mailer.send_converted_to_spam_notification
      @rev_tracker.phase.must_equal 'spam'
    end

    it 'should reset the status to pending' do
      Reverification::Mailer.send_converted_to_spam_notification
      @rev_tracker.status.must_equal 'pending'
    end

    it 'should reset the attempts to 1' do
      Reverification::Mailer.send_converted_to_spam_notification
      @rev_tracker.attempts.must_equal 1
    end

    it 'should update the sent_at time' do
      Reverification::Mailer.send_converted_to_spam_notification
      @rev_tracker.sent_at.to_date.must_equal Date.today
    end
  end

  describe 'send_final_notification' do
    before do
      @rev_tracker = create(:spam_rev_tracker, :delivered, account: unverified_account_sucess, sent_at: Time.now.utc - Reverification::Mailer::NOTIFICATION3_DUE_DAYS.days)
      ReverificationTracker.expects(:expired_third_phase_notifications).returns [@rev_tracker]
    end

    it 'should send correct email template' do
      Reverification::Template.expects(:final_warning_notice)
      Reverification::Mailer.send_final_notification
    end

    it 'should change the phase to spam' do
      Reverification::Mailer.send_final_notification
      @rev_tracker.phase.must_equal 'final_warning'
    end

    it 'should reset the status to pending' do
      Reverification::Mailer.send_final_notification
      @rev_tracker.status.must_equal 'pending'
    end

    it 'should reset the attempts to 1' do
      Reverification::Mailer.send_final_notification
      @rev_tracker.attempts.must_equal 1
    end

    it 'should update the sent_at time' do
      Reverification::Mailer.send_final_notification
      @rev_tracker.sent_at.to_date.must_equal Date.today
    end
  end

  describe 'resend_soft_bounced_notifications' do
    describe 'initial notification' do
      before do
        @rev_tracker = create(:reverification_tracker, :soft_bounced, attempts: 1, sent_at: Time.now.utc - 1.day, account: unverified_account_sucess)
      end

      it 'should send the same email content' do
        Reverification::Template.expects(:first_reverification_notice)
        Reverification::Mailer.resend_soft_bounced_notifications
      end

      it 'should not change the phase' do
        Reverification::Mailer.resend_soft_bounced_notifications
        @rev_tracker.reload.must_be :initial?
      end

      it 'should increment attempts by one' do
        @rev_tracker.attempts.must_equal 1
        Reverification::Mailer.resend_soft_bounced_notifications
        @rev_tracker.reload.attempts.must_equal 2
      end

      it 'should update the sent_at time' do
        @rev_tracker.sent_at.to_date.wont_equal Date.today
        Reverification::Mailer.resend_soft_bounced_notifications
        @rev_tracker.reload.sent_at.to_date.must_equal Date.today
      end

      it 'should not resend email when sent_at is not lesser than current date' do
        @rev_tracker.update sent_at: Time.now.utc
        Reverification::Template.expects(:first_reverification_notice).never
        Reverification::Mailer.resend_soft_bounced_notifications
      end

      it 'should not resend an email when ses limit has been reached' do
        Reverification::Process.expects(:ses_limit_reached?).returns(true)
        AWS::SimpleEmailService.any_instance.expects(:send_email).never
        Reverification::Mailer.resend_soft_bounced_notifications
      end
    end

    describe 'marked for spam notification' do
      before do
        @rev_tracker = create(:marked_for_spam_rev_tracker, :soft_bounced, attempts: 1, sent_at: Time.now.utc - 1.day, account: unverified_account_sucess)
      end

      it 'should send the same email content' do
        Reverification::Template.expects(:marked_for_spam_notice)
        Reverification::Mailer.resend_soft_bounced_notifications
      end

      it 'should not change the phase' do
        Reverification::Mailer.resend_soft_bounced_notifications
        @rev_tracker.reload.must_be :marked_for_spam?
      end

      it 'should increment attempts by one' do
        @rev_tracker.attempts.must_equal 1
        Reverification::Mailer.resend_soft_bounced_notifications
        @rev_tracker.reload.attempts.must_equal 2
      end

      it 'should update the sent_at time' do
        @rev_tracker.sent_at.to_date.wont_equal Date.today
        Reverification::Mailer.resend_soft_bounced_notifications
        @rev_tracker.reload.sent_at.to_date.must_equal Date.today
      end

      it 'should not resend email when sent_at is not lesser than current date' do
        @rev_tracker.update sent_at: Time.now.utc
        Reverification::Template.expects(:marked_for_spam_notice).never
        Reverification::Mailer.resend_soft_bounced_notifications
      end
    end

    describe 'spam notification' do
      before do
        @rev_tracker = create(:spam_rev_tracker, :soft_bounced, attempts: 1, sent_at: Time.now.utc - 1.day, account: unverified_account_sucess)
      end

      it 'should send the same email content' do
        Reverification::Template.expects(:account_is_spam_notice)
        Reverification::Mailer.resend_soft_bounced_notifications
      end

      it 'should not change the phase' do
        Reverification::Mailer.resend_soft_bounced_notifications
        @rev_tracker.reload.must_be :spam?
      end

      it 'should increment attempts by one' do
        @rev_tracker.attempts.must_equal 1
        Reverification::Mailer.resend_soft_bounced_notifications
        @rev_tracker.reload.attempts.must_equal 2
      end

      it 'should update the sent_at time' do
        @rev_tracker.sent_at.to_date.wont_equal Date.today
        Reverification::Mailer.resend_soft_bounced_notifications
        @rev_tracker.reload.sent_at.to_date.must_equal Date.today
      end

      it 'should not resend email when sent_at is not lesser than current date' do
        @rev_tracker.update sent_at: Time.now.utc
        Reverification::Template.expects(:account_is_spam_notice).never
        Reverification::Mailer.resend_soft_bounced_notifications
      end
    end

    describe 'final warning notification' do
      before do
        @rev_tracker = create(:final_warning_rev_tracker, :soft_bounced, attempts: 1, sent_at: Time.now.utc - 1.day, account: unverified_account_sucess)
      end

      it 'should send the same email content' do
        Reverification::Template.expects(:final_warning_notice)
        Reverification::Mailer.resend_soft_bounced_notifications
      end

      it 'should not change the phase' do
        Reverification::Mailer.resend_soft_bounced_notifications
        @rev_tracker.reload.must_be :final_warning?
      end

      it 'should increment attempts by one' do
        @rev_tracker.attempts.must_equal 1
        Reverification::Mailer.resend_soft_bounced_notifications
        @rev_tracker.reload.attempts.must_equal 2
      end

      it 'should update the sent_at time' do
        @rev_tracker.sent_at.to_date.wont_equal Date.today
        Reverification::Mailer.resend_soft_bounced_notifications
        @rev_tracker.reload.sent_at.to_date.must_equal Date.today
      end

      it 'should not resend email when sent_at is not lesser than current date' do
        @rev_tracker.update sent_at: Time.now.utc
        Reverification::Template.expects(:final_warning_notice).never
        Reverification::Mailer.resend_soft_bounced_notifications
      end
    end
  end
end
