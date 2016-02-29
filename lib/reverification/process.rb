module Reverification
  class Process
    SAMPLE_COUNT = 5000

    class << self
      def run
        delete_unverified_spam_accounts
        send_notifications
      end

      def send_notifications
        unless Reverification::Mailer.ses_limit_reached?
          send_final_notification
          send_account_is_spam_notification
          send_marked_for_spam_notification
          send_first_notification
        end
      end

      def send_final_notification
        ReverificationTracker.spam_phase_accounts(SAMPLE_COUNT).each do |rev_track|
          next unless rev_track.updated_at.to_date + 6.day == Date.today
          Mailer.send(Reverification::Template.one_day_before_deletion_notice(rev_track.account.email, rev_track.account, 3))
        end
      end

      def send_account_is_spam_notification
        ReverificationTracker.marked_for_spam_phase_accounts(SAMPLE_COUNT).each do |rev_track|
          next unless rev_track.updated_at.to_date + 1.day == Date.today
          Mailer.send(Reverification::Template.account_is_spam_notice(rev_track.account.email, rev_track.account, 2))
        end
      end

      def send_marked_for_spam_notification
        ReverificationTracker.initial_phase_accounts(SAMPLE_COUNT).each do |rev_track|
          next unless rev_track.updated_at.to_date + 14.days == Date.today
          Mailer.send(Reverification::Template.marked_for_spam_notice(rev_track.account.email, rev_track.account, 1))
        end
      end

      def send_first_notification
        Account.reverification_not_initiated(SAMPLE_COUNT).each do |account|
          Reverification::Mailer.send(Reverification::Template.first_reverification_notice(account.email), account, 0)
        end
      end

      def delete_unverified_spam_accounts
        Account.where(level: -20).includes(:reverification_tracker).find_each do |account|
          if account.reverification_tracker.final_warning? && gt_equal(account.reverification_tracker.updated_at)
            account.destroy
          end
        end
      end
    end
  end
end