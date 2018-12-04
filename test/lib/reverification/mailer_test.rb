require 'test_helper'
require 'test_helpers/reverification'

class Reverification::MailerTest < ActiveSupport::TestCase
  describe 'constants' do
    it 'should have beeen defined' do
      assert_equal 3, ReverificationTracker::MAX_ATTEMPTS
      assert_equal 21, ReverificationTracker::NOTIFICATION1_DUE_DAYS
      assert_equal 140, ReverificationTracker::NOTIFICATION2_DUE_DAYS
      assert_equal 28, ReverificationTracker::NOTIFICATION3_DUE_DAYS
      assert_equal 14, ReverificationTracker::NOTIFICATION4_DUE_DAYS
      assert_equal 'info@openhub.net', Reverification::Mailer::FROM
    end
  end

  describe 'run' do
    it 'should invoke notifications sending methods' do
      Reverification::Mailer.expects(:send_notifications)
      Reverification::Mailer.expects(:resend_soft_bounced_notifications)
      Reverification::Mailer.run
    end
  end

  describe 'send_notifications' do
    it 'should send notifications to accounts' do
      Reverification::Mailer.expects(:send_final_notification)
      Reverification::Mailer.expects(:send_account_is_disabled_notification)
      Reverification::Mailer.expects(:send_marked_for_disable_notification)
      Reverification::Mailer.expects(:send_first_notification)
      Reverification::Mailer.send_notifications
    end
  end

  describe 'badly formatted email failure scenario' do
    before do
      Aws::SES::Client.any_instance.stubs(:get_send_quota).returns(MOCK::AWS::SimpleEmailService.send_quota)
      below_specified_settings = MOCK::AWS::SimpleEmailService.amazon_stat_settings
      Reverification::Mailer.stubs(:amazon_stat_settings).returns(below_specified_settings)
    end

    # rubocop: disable Layout/CommentIndentation
    # FIXME: Fix this test in accordance with new AWS 2.x upgrade.
    # it 'should handle the InvalidParameter exception' do
      # bad_account = create(:unverified_account)
      # bad_account.update(email: 'bad  email@gmail.com')
      # template = { source: 'info@openhub.net', destination: { to_addresses: [bad_account.email] },
                   # message: { subject: { data: 'Hi' }, body: { text: { data: 'hello' } } } }
      # bad_email_queue = mock('AWS::SQS::Queue::MOCK')
      # Reverification::Mailer.stubs(:bad_email_queue).returns(bad_email_queue)
      # Aws::SES::Client.any_instance.stubs(:send_email).with(template)
                      # .raises(Aws::SES::Errors::InvalidParameterValue)
      # bad_email_queue.expects(:send_message).with("Account id: #{bad_account.id} with email: #{bad_account.email}")
      # Reverification::Mailer.send_email(template, bad_account, 0)
      # bad_account.reverification_tracker.must_be_nil
    # end
    # rubocop: enable Layout/CommentIndentation
  end

  describe 'send_email' do
    before do
      # Settings need to be below specified settings to avoid statistics checking
      Aws::SES::Client.any_instance.stubs(:get_send_quota).returns(MOCK::AWS::SimpleEmailService.send_quota)
      below_specified_settings = MOCK::AWS::SimpleEmailService.amazon_stat_settings
      Reverification::Mailer.stubs(:amazon_stat_settings).returns(below_specified_settings)
      Aws::SES::Client.any_instance.stubs(:send_email).returns(MOCK::AWS::SimpleEmailService.response)
    end
    let(:unverified_account) { create(:unverified_account) }
    let(:unverified_account_sucess) { create(:unverified_account, :success) }

    describe 'First notification' do
      before do
        unverified_account.reverification_tracker.must_be_nil
      end

      it 'should create a reverification tracker' do
        data = { source: 'foo', destination: { to_addresses: ['bar'] },
                 message: { subject: { data: 'foobar' },
                            body: { text: { data: 'foobar' } } } }
        Reverification::Mailer.send_email(data, unverified_account, 0)
        unverified_account.reverification_tracker.must_be :present?
        unverified_account.reverification_tracker.must_be :initial?
        unverified_account.reverification_tracker.must_be :pending?
        assert_equal 1, unverified_account.reverification_tracker.attempts
        assert_equal Time.zone.now.to_date, unverified_account.reverification_tracker.sent_at.to_date
      end
    end

    describe 'Second/subsequent notification' do
      before do
        Reverification::Mailer.send_email('dummy - first email content', unverified_account, 0)
        unverified_account.reverification_tracker.delivered!
      end

      it 'should update reverification tracker attributes - phase, status, attempts and sent_at' do
        Reverification::Mailer.send_email('dummy - second email content', unverified_account, 1)
        unverified_account.reverification_tracker.wont_be :initial?
        unverified_account.reverification_tracker.must_be :pending?
        assert_equal 1, unverified_account.reverification_tracker.attempts
        assert_equal Time.zone.now.to_date, unverified_account.reverification_tracker.sent_at.to_date
      end
    end

    describe 'Resend notification' do
      before do
        Reverification::Mailer.send_email('dummy - first email content', unverified_account, 0)
        unverified_account.reverification_tracker.must_be :present?
        unverified_account.reverification_tracker.must_be :initial?
        unverified_account.reverification_tracker.must_be :pending?
        assert_equal 1, unverified_account.reverification_tracker.attempts
        assert_equal Time.zone.now.to_date, unverified_account.reverification_tracker.sent_at.to_date
        unverified_account.reverification_tracker.soft_bounced!
        unverified_account.reverification_tracker.must_be :soft_bounced?
      end

      it 'should update reverification tracker attributes - status, attempts and sent_at' do
        Reverification::Mailer.send_email('dummy - first email content', unverified_account, 0)
        unverified_account.reverification_tracker.must_be :initial?
        unverified_account.reverification_tracker.must_be :pending?
        assert_equal 2, unverified_account.reverification_tracker.attempts
        assert_equal Time.zone.now.to_date, unverified_account.reverification_tracker.sent_at.to_date
      end

      it 'should check bounce and complaint rate when
        total mails sent in last 24 hours reaches the amount_of_email defined' do
        Aws::SES::Client.any_instance.stubs(:get_send_quota).returns(stub(sent_last_24_hours: 1000))
        Reverification::Mailer.expects(:check_statistics_of_last_24_hrs)
        Reverification::Mailer.send_email('dummy email content', unverified_account, 0)
      end

      it 'should not check bounce and complaint rate when
        total mails sent in last 24 hours below the amount_of_email defined' do
        Aws::SES::Client.any_instance.stubs(:get_send_quota).returns(stub(sent_last_24_hours: 999))
        Reverification::Mailer.expects(:check_statistics_of_last_24_hrs).never
        Reverification::Mailer.send_email('dummy email content', unverified_account, 0)
      end
    end

    describe 'send_first_notification' do
      it 'should send notification to unverified accounts only' do
        below_specified_settings = MOCK::AWS::SimpleEmailService.amazon_stat_settings
        Reverification::Mailer.stubs(:amazon_stat_settings).returns(below_specified_settings)
        Account.expects(:reverification_not_initiated).returns([unverified_account_sucess])
        Reverification::Template.expects(:first_reverification_notice)
        unverified_account_sucess.reverification_tracker.must_be_nil

        Reverification::Mailer.send_first_notification
        unverified_account_sucess.reload.reverification_tracker.must_be :present?
        unverified_account_sucess.reverification_tracker.phase.must_equal 'initial'
        unverified_account_sucess.reverification_tracker.attempts.must_equal 1
        unverified_account_sucess.reverification_tracker.sent_at.to_date.must_equal Time.zone.now.to_date
      end
    end

    describe 'marked_for_disable_notice' do
      before do
        sent_at = Time.now.utc - ReverificationTracker::NOTIFICATION1_DUE_DAYS.days
        @rev_tracker = create(:success_initial_rev_tracker, account: unverified_account_sucess, sent_at: sent_at)
        ReverificationTracker.expects(:expired_initial_phase_notifications).returns [@rev_tracker]
        below_specified_settings = MOCK::AWS::SimpleEmailService.amazon_stat_settings
        Reverification::Mailer.stubs(:amazon_stat_settings).returns(below_specified_settings)
      end

      it 'should send correct email template' do
        Reverification::Template.expects(:marked_for_disable_notice)
        Reverification::Mailer.send_marked_for_disable_notification
      end

      it 'should change the phase to marked_for_disable' do
        Reverification::Mailer.send_marked_for_disable_notification
        @rev_tracker.phase.must_equal 'marked_for_disable'
      end

      it 'should reset the status to pending' do
        Reverification::Mailer.send_marked_for_disable_notification
        @rev_tracker.status.must_equal 'pending'
      end

      it 'should reset the attempts to 1' do
        Reverification::Mailer.send_marked_for_disable_notification
        @rev_tracker.attempts.must_equal 1
      end

      it 'should update the sent_at time' do
        Reverification::Mailer.send_marked_for_disable_notification
        @rev_tracker.sent_at.to_date.must_equal Time.zone.now.to_date
      end
    end

    describe 'send account is disable notice' do
      before do
        @rev_tracker = create(:marked_for_disable_rev_tracker,
                              :delivered,
                              account: unverified_account_sucess,
                              sent_at: Time.now.utc - ReverificationTracker::NOTIFICATION2_DUE_DAYS.days)
        ReverificationTracker.expects(:expired_second_phase_notifications).returns [@rev_tracker]
        below_specified_settings = MOCK::AWS::SimpleEmailService.amazon_stat_settings
        Reverification::Mailer.stubs(:amazon_stat_settings).returns(below_specified_settings)
      end

      it 'should send correct email template' do
        Reverification::Template.expects(:account_is_disabled_notice)
        Reverification::Mailer.send_account_is_disabled_notification
      end

      it 'should change the phase to disabled' do
        Reverification::Mailer.send_account_is_disabled_notification
        @rev_tracker.phase.must_equal 'disabled'
      end

      it 'should reset the status to pending' do
        Reverification::Mailer.send_account_is_disabled_notification
        @rev_tracker.status.must_equal 'pending'
      end

      it 'should reset the attempts to 1' do
        Reverification::Mailer.send_account_is_disabled_notification
        @rev_tracker.attempts.must_equal 1
      end

      it 'should update the sent_at time' do
        Reverification::Mailer.send_account_is_disabled_notification
        @rev_tracker.sent_at.to_date.must_equal Time.zone.now.to_date
      end
    end

    describe 'send_final_notification' do
      before do
        @rev_tracker = create(:disable_rev_tracker,
                              :delivered,
                              account: unverified_account_sucess,
                              sent_at: Time.now.utc - ReverificationTracker::NOTIFICATION3_DUE_DAYS.days)
        ReverificationTracker.expects(:expired_third_phase_notifications).returns [@rev_tracker]
        below_specified_settings = MOCK::AWS::SimpleEmailService.amazon_stat_settings
        Reverification::Mailer.stubs(:amazon_stat_settings).returns(below_specified_settings)
      end

      it 'should send correct email template' do
        Reverification::Template.expects(:final_warning_notice)
        Reverification::Mailer.send_final_notification
      end

      it 'should change the phase to final warning' do
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
        @rev_tracker.sent_at.to_date.must_equal Time.zone.now.to_date
      end
    end

    describe 'resend_soft_bounced_notifications' do
      describe 'initial notification' do
        before do
          @rev_tracker = create(:reverification_tracker,
                                :soft_bounced,
                                account: unverified_account_sucess,
                                attempts: 1,
                                sent_at: Time.now.utc - 1.day)
          below_specified_settings = MOCK::AWS::SimpleEmailService.amazon_stat_settings
          Reverification::Mailer.stubs(:amazon_stat_settings).returns(below_specified_settings)
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
          @rev_tracker.sent_at.to_date.wont_equal Time.zone.now.to_date
          Reverification::Mailer.resend_soft_bounced_notifications
          @rev_tracker.reload.sent_at.to_date.must_equal Time.zone.now.to_date
        end

        it 'should not resend email when sent_at is not lesser than current date' do
          @rev_tracker.update sent_at: Time.now.utc
          Reverification::Template.expects(:first_reverification_notice).never
          Reverification::Mailer.resend_soft_bounced_notifications
        end
      end

      describe 'resend marked for disable notification' do
        before do
          @rev_tracker = create(:marked_for_disable_rev_tracker,
                                :soft_bounced,
                                account: unverified_account_sucess,
                                attempts: 1,
                                sent_at: Time.now.utc - 1.day)
          below_specified_settings = MOCK::AWS::SimpleEmailService.amazon_stat_settings
          Reverification::Mailer.stubs(:amazon_stat_settings).returns(below_specified_settings)
        end

        it 'should send the same email content' do
          Reverification::Template.expects(:marked_for_disable_notice)
          Reverification::Mailer.resend_soft_bounced_notifications
        end

        it 'should not change the phase' do
          Reverification::Mailer.resend_soft_bounced_notifications
          @rev_tracker.reload.must_be :marked_for_disable?
        end

        it 'should increment attempts by one' do
          @rev_tracker.attempts.must_equal 1
          Reverification::Mailer.resend_soft_bounced_notifications
          @rev_tracker.reload.attempts.must_equal 2
        end

        it 'should update the sent_at time' do
          @rev_tracker.sent_at.to_date.wont_equal Time.zone.now.to_date
          Reverification::Mailer.resend_soft_bounced_notifications
          @rev_tracker.reload.sent_at.to_date.must_equal Time.zone.now.to_date
        end

        it 'should not resend email when sent_at is not lesser than current date' do
          @rev_tracker.update sent_at: Time.now.utc
          Reverification::Template.expects(:marked_for_disable_notice).never
          Reverification::Mailer.resend_soft_bounced_notifications
        end
      end

      describe 'account is disable notification' do
        before do
          @rev_tracker = create(:disable_rev_tracker,
                                :soft_bounced,
                                account: unverified_account_sucess,
                                attempts: 1,
                                sent_at: Time.now.utc - 1.day)
          below_specified_settings = MOCK::AWS::SimpleEmailService.amazon_stat_settings
          Reverification::Mailer.stubs(:amazon_stat_settings).returns(below_specified_settings)
        end

        it 'should send the same email content' do
          Reverification::Template.expects(:account_is_disabled_notice)
          Reverification::Mailer.resend_soft_bounced_notifications
        end

        it 'should not change the phase' do
          Reverification::Mailer.resend_soft_bounced_notifications
          @rev_tracker.reload.must_be :disabled?
        end

        it 'should increment attempts by one' do
          @rev_tracker.attempts.must_equal 1
          Reverification::Mailer.resend_soft_bounced_notifications
          @rev_tracker.reload.attempts.must_equal 2
        end

        it 'should update the sent_at time' do
          @rev_tracker.sent_at.to_date.wont_equal Time.zone.now.to_date
          Reverification::Mailer.resend_soft_bounced_notifications
          @rev_tracker.reload.sent_at.to_date.must_equal Time.zone.now.to_date
        end

        it 'should not resend email when sent_at is not lesser than current date' do
          @rev_tracker.update sent_at: Time.now.utc
          Reverification::Template.expects(:account_is_disabled_notice).never
          Reverification::Mailer.resend_soft_bounced_notifications
        end
      end

      describe 'final warning notification' do
        before do
          @rev_tracker = create(:final_warning_rev_tracker,
                                :soft_bounced,
                                account: unverified_account_sucess,
                                attempts: 1,
                                sent_at: Time.now.utc - 1.day)
          below_specified_settings = MOCK::AWS::SimpleEmailService.amazon_stat_settings
          Reverification::Mailer.stubs(:amazon_stat_settings).returns(below_specified_settings)
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
          @rev_tracker.sent_at.to_date.wont_equal Time.zone.now.to_date
          Reverification::Mailer.resend_soft_bounced_notifications
          @rev_tracker.reload.sent_at.to_date.must_equal Time.zone.now.to_date
        end

        it 'should not resend email when sent_at is not lesser than current date' do
          @rev_tracker.update sent_at: Time.now.utc
          Reverification::Template.expects(:final_warning_notice).never
          Reverification::Mailer.resend_soft_bounced_notifications
        end
      end
    end
  end
end
