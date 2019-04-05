module Reverification
  class Mailer
    extend Amazon
    FROM = 'info@openhub.net'.freeze

    class << self
      def first_notice_template(account)
        Reverification::Template.first_reverification_notice(account.email)
      end

      def second_notice_template(rev_track)
        Reverification::Template.marked_for_disable_notice(rev_track.account.email)
      end

      def third_notice_template(rev_track)
        Reverification::Template.account_is_disabled_notice(rev_track.account.email)
      end

      def fourth_notice_template(rev_track)
        Reverification::Template.final_warning_notice(rev_track.account.email)
      end

      def initial_accounts
        Account.reverification_not_initiated(send_limit)
      end

      def expired_initial_phase_notifications
        ReverificationTracker.expired_initial_phase_notifications(send_limit)
      end

      def expired_second_phase_notifications
        ReverificationTracker.expired_second_phase_notifications(send_limit)
      end

      def expired_third_phase_notifications
        ReverificationTracker.expired_third_phase_notifications(send_limit)
      end

      def soft_bounced_notifications
        ReverificationTracker.soft_bounced_until_yesterday.max_attempts_not_reached.limit(send_limit)
      end

      def run
        resend_soft_bounced_notifications
        send_notifications
      end

      def send_notifications
        send_final_notification
        send_account_is_disabled_notification
        send_marked_for_disable_notification
        send_first_notification
      end

      def send_email(template, account, phase)
        check_statistics_and_wait_to_avoid_exceeding_throttle_limit
        begin
          resp = ses.send_email(template)
        rescue Aws::SES::Errors::InvalidParameterValue
          bad_email_queue.send_message("Account id: #{account.id} with email: #{account.email}")
        else
          create_or_update_reverification_tracker(account, phase, resp)
        end
      end

      def send_first_notification
        initial_accounts.each do |account|
          account = Account.find(account.id)
          send_email(first_notice_template(account), account, 0)
        end
      end

      def send_marked_for_disable_notification
        expired_initial_phase_notifications.each do |rev_track|
          send_email(second_notice_template(rev_track), rev_track.account, 1)
        end
      end

      def send_account_is_disabled_notification
        expired_second_phase_notifications.each do |rev_track|
          send_email(third_notice_template(rev_track), rev_track.account, 2)
        end
      end

      def send_final_notification
        expired_third_phase_notifications.each do |rev_track|
          send_email(fourth_notice_template(rev_track), rev_track.account, 3)
        end
      end

      def resend_soft_bounced_notifications
        soft_bounced_notifications.each do |rev_track|
          send_email(rev_track.template_hash, rev_track.account, rev_track.phase_value)
        end
      end

      private

      def create_or_update_reverification_tracker(account, phase, resp)
        if account.reverification_tracker
          return ReverificationTracker.update_tracker(account.reverification_tracker, phase, resp)
        end

        account.create_reverification_tracker(message_id: resp[:message_id], sent_at: Time.now.utc)
      end
    end
  end
end
