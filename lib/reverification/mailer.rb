module Reverification
  class Mailer
    FROM = 'info@openhub.net'
    SAMPLE_COUNT = 5000
    MAX_ATTEMPTS = 3
    NOTIFICATION1_DUE_DAYS = 14
    NOTIFICATION2_DUE_DAYS = 14
    NOTIFICATION3_DUE_DAYS = 14
    NOTIFICATION4_DUE_DAYS = 14

    class << self
      def run
        resend_soft_bounced_notifications
        send_notifications
      end

      def send_notifications
        send_final_notification
        send_converted_to_spam_notification
        send_marked_for_spam_notification
        send_first_notification
      end

      def send_first_notification
        Account.reverification_not_initiated(SAMPLE_COUNT).each do |account|
          Reverification::Process.send_email(
            Reverification::Template.first_reverification_notice(account.email),
            account, 0)
        end
      end

      def send_marked_for_spam_notification
        ReverificationTracker.expired_initial_phase_notifications(SAMPLE_COUNT).each do |rev_track|
          Reverification::Process.send_email(
            Reverification::Template.marked_for_spam_notice(rev_track.account.email),
            rev_track.account, 1)
        end
      end

      def send_converted_to_spam_notification
        ReverificationTracker.expired_second_phase_notifications(SAMPLE_COUNT).each do |rev_track|
          Reverification::Process.send_email(
            Reverification::Template.account_is_spam_notice(rev_track.account.email),
            rev_track.account, 2)
        end
      end

      def send_final_notification
        ReverificationTracker.expired_third_phase_notifications(SAMPLE_COUNT).each do |rev_track|
          Reverification::Process.send_email(
            Reverification::Template.final_warning_notice(rev_track.account.email),
            rev_track.account, 3)
        end
      end

      def resend_soft_bounced_notifications
        # Grab all the soft_bounced trackers
        ReverificationTracker.soft_bounced_until_yesterday.max_attempts_not_reached
          .find_each(batch_size: SAMPLE_COUNT) do |rev_track|
          Reverification::Process.send_email(rev_track.template_hash, rev_track.account, rev_track.phase_value)
        end
      end
    end
  end
end
