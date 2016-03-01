module Reverification
  class Mailer
    SAMPLE_COUNT = 5000

    class << self
      def run
        delete_unverified_spam_accounts
        send_notifications
      end

      def send_notifications
        unless Reverification::Process.ses_limit_reached?
          send_final_notification
          send_converted_to_spam_notification
          send_marked_for_spam_notification
          send_first_notification
        end
      end

      def send_final_notification
        ReverificationTracker.spam_phase_accounts(SAMPLE_COUNT).each do |rev_track|
          updated_at = rev_track.updated_at.to_date
          next unless updated_at + 6.day >= Date.today && updated_at < updated_at + 7.day
          Reverification::Process.send(Reverification::Template.one_day_before_deletion_notice(rev_track.account.email), rev_track.account, 3)
        end
      end

      def send_converted_to_spam_notification
        ReverificationTracker.marked_for_spam_phase_accounts(SAMPLE_COUNT).each do |rev_track|
          next unless rev_track.updated_at.to_date + 1.day >= Date.today
          Reverification::Process.send(Reverification::Template.account_is_spam_notice(rev_track.account.email), rev_track.account, 2)
        end
      end

      def send_marked_for_spam_notification
        ReverificationTracker.initial_phase_accounts(SAMPLE_COUNT).each do |rev_track|
          next unless rev_track.updated_at.to_date + 14.days >= Date.today
          Reverification::Process.send(Reverification::Template.marked_for_spam_notice(rev_track.account.email), rev_track.account, 1)
        end
      end

      def send_first_notification
        Account.reverification_not_initiated(SAMPLE_COUNT).each do |account|
          notification = Reverification::Template.first_reverification_notice(account.email)
          resp = Reverification::Process.send(notification)
          account.create_reverification_tracker(message_id: resp[:message_id])
          account.reverification_tracker.initial!
          account.reverification_tracker.pending!
        end
      end

      def delete_unverified_spam_accounts
        accounts = Account.where(level: -20).joins(:reverification_tracker).where.not(id: Verification.select(:account_id))
        accounts.each do |account|
          if account.reverification_tracker.final_warning? && account.reverification_tracker.updated_at.to_date >= Date.today
            account.destroy
          end
        end
      end
    end
  end
end
