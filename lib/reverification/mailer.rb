module Reverification
  class Mailer
    SAMPLE_COUNT = 5000
    MAX_ATTEMPTS = 3

    class << self
      def run
        delete_unverified_spam_accounts
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

      def send_final_notification
        ReverificationTracker.spam_phase_accounts(SAMPLE_COUNT).each do |rev_track|
          updated_at = rev_track.updated_at.to_date
          next unless updated_at + 6.days >= Date.today && updated_at < updated_at + 7.days
          Reverification::Process.send(
            Reverification::Template.one_day_before_deletion_notice(rev_track.account.email),
            rev_track.account, 3)
        end
      end

      def send_converted_to_spam_notification
        ReverificationTracker.marked_for_spam_phase_accounts(SAMPLE_COUNT).each do |rev_track|
          next if rev_track.sent_at.to_date + 1.day > Date.today
          Reverification::Process.send(
            Reverification::Template.account_is_spam_notice(rev_track.account.email),
            rev_track.account, 2)
        end
      end

      def send_marked_for_spam_notification
        ReverificationTracker.initial_phase_accounts(SAMPLE_COUNT).each do |rev_track|
          next if rev_track.sent_at.to_date + 14.days > Date.today
          Reverification::Process.send(
            Reverification::Template.marked_for_spam_notice(rev_track.account.email),
            rev_track.account, 1)
        end
      end

      def send_first_notification
        Account.reverification_not_initiated(SAMPLE_COUNT).each do |account|
          Reverification::Process.send(
            Reverification::Template.first_reverification_notice(account.email),
            account, 0)
        end
      end

      def resend_soft_bounced_notifications
        # Grab all the soft_bounced trackers
        ReverificationTracker.soft_bounced.till_yesterday.find_each(batch_size: SAMPLE_COUNT) do |notification|
          if notification.initial?
            Reverification::Process.send(
              Reverification::Template.first_reverification_notice(notification.account.email),
              notification.account, 0)
          elsif notification.marked_for_spam?
            Reverification::Process.send(
              Reverification::Template.marked_for_spam_notice(notification.account.email),
              notification.account, 1)
          elsif notification.spam?
            Reverification::Process.send(
              Reverification::Template.account_is_spam_notice(notification.account.email),
              notification.account, 2)
          elsif notification.final_warning?
            Reverification::Process.send(
              Reverification::Template.one_day_before_deletion_notice(notification.account.email),
              notification.account, 3)
          end
        end
      end
    end
  end
end
