module Reverification
  class Mailer
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
        return if Reverification::Process.ses_limit_reached?
        send_final_notification
        send_converted_to_spam_notification
        send_marked_for_spam_notification
        send_first_notification
      end

      def send_first_notification
        return if Reverification::Process.ses_limit_reached?
        Account.reverification_not_initiated(SAMPLE_COUNT).each do |account|
          Reverification::Process.send_email(
            Reverification::Template.first_reverification_notice(account.email),
            account, 0)
        end
      end

      def send_marked_for_spam_notification
        return if Reverification::Process.ses_limit_reached?
        ReverificationTracker.expired_initial_phase_notifications(SAMPLE_COUNT).each do |rev_track|
          Reverification::Process.send_email(
            Reverification::Template.marked_for_spam_notice(rev_track.account.email),
            rev_track.account, 1)
        end
      end

      def send_converted_to_spam_notification
        return if Reverification::Process.ses_limit_reached?
        ReverificationTracker.expired_second_phase_notifications(SAMPLE_COUNT).each do |rev_track|
          Reverification::Process.send_email(
            Reverification::Template.account_is_spam_notice(rev_track.account.email),
            rev_track.account, 2)
        end
      end

      def send_final_notification
        return if Reverification::Process.ses_limit_reached?
        ReverificationTracker.expired_third_phase_notifications(SAMPLE_COUNT).each do |rev_track|
          Reverification::Process.send_email(
            Reverification::Template.one_day_before_deletion_notice(rev_track.account.email),
            rev_track.account, 3)
        end
      end

      def resend_soft_bounced_notifications
        # Grab all the soft_bounced trackers
        ReverificationTracker.soft_bounced_until_yesterday.max_attempts_not_reached.find_each(batch_size: SAMPLE_COUNT) do |notification|
          if notification.initial?
            Reverification::Process.send_email(
              Reverification::Template.first_reverification_notice(notification.account.email),
              notification.account, 0)
          elsif notification.marked_for_spam?
            Reverification::Process.send_email(
              Reverification::Template.marked_for_spam_notice(notification.account.email),
              notification.account, 1)
          elsif notification.spam?
            Reverification::Process.send_email(
              Reverification::Template.account_is_spam_notice(notification.account.email),
              notification.account, 2)
          elsif notification.final_warning?
            Reverification::Process.send_email(
              Reverification::Template.one_day_before_deletion_notice(notification.account.email),
              notification.account, 3)
          end
        end
      end
    end
  end
end
