# rubocop:disable Metrics/ClassLength
class ReverificationTracker < ActiveRecord::Base
  belongs_to :account

  enum status: [:pending, :delivered, :bounced, :complained, :auto_responded]
  enum phase: [:initial, :marked_for_spam, :spam, :final_warning]

  class << self
    def spam_phase_accounts(limit = nil)
      spam.limit(limit)
    end

    def marked_for_spam_phase_accounts(limit = nil)
      marked_for_spam.limit(limit)
    end

    def initial_phase_accounts(limit = nil)
      initial.limit(limit)
    end

    def destroy_account(email_address)
      account = Account.find_by_email(email_address)
      account.destroy if account
    end

    def determine_correct_notification_to_send(rev_tracker)
      if rev_tracker.initial?
        send_mail(first_reverification_notice(rev_tracker.account.email), rev_tracker.account, rev_tracker.phase)
      end
      # if account.reverification_tracker.spam?
      #   ses.send_email(one_day_before_deletion_notice(account.email))
      # elsif account.reverification_tracker.marked_for_spam?
      #   ses.send_email(account_is_spam_notice(account.email))
      # else
      #   ses.send_email(marked_for_spam_notice(account.email))
      # end
    end

    def cleanup
      find_each do |rev_tracker|
        rev_tracker.destroy if rev_tracker.account.access.mobile_or_oauth_verified?
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
