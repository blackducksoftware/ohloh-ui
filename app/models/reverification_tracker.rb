class ReverificationTracker < ActiveRecord::Base
  belongs_to :account
  enum status: [:pending, :delivered, :soft_bounced, :complained, :auto_responded]
  enum phase: [:initial, :marked_for_spam, :spam, :final_warning]

  scope :till_yesterday, -> { where('DATE(sent_at) < DATE(NOW())').order(sent_at: :asc) }
  scope :max_attempts_not_reached, -> { where("attempts < #{Reverification::Mailer::MAX_ATTEMPTS}") }
  scope :max_attempts_reached, -> { where("attempts >= #{Reverification::Mailer::MAX_ATTEMPTS}") }
  scope :initial_soft_bounced, -> ( limit = nil ) { initial.soft_bounced.limit(limit) }

  def max_attempts_reached?
    attempts >= Reverification::Mailer::MAX_ATTEMPTS
  end

  class << self
    # def spam_phase_accounts(limit = nil)
    #   spam.limit(limit)
    # end

    # def marked_for_spam_phase_accounts(limit = nil)
    #   marked_for_spam.limit(limit)
    # end

    # def initial_phase_accounts(limit = nil)
    #   initial.limit(limit)
    # end

    def destroy_account(email_address)
      account = Account.find_by_email(email_address)
      account.destroy if account
    end

    # def determine_correct_notification_to_send(rev_tracker)
    #   if rev_tracker.initial?
    #     Reverification::Mailer.send(first_reverification_notice(rev_tracker.account.email))
    #     rev_tracker.pending!
    #   end
    # end

    # def delete_unverified_spam_accounts
    #   accounts = Account.where(level: -20).joins(:reverification_tracker).where.not(id: Verification.select(:account_id))
    #   accounts.each do |account|
    #     if account.reverification_tracker.final_warning? && account.reverification_tracker.updated_at.to_date >= Date.today
    #       account.destroy
    #     end
    #   end
    # end

    def cleanup
      find_each do |rev_tracker|
        rev_tracker.destroy if rev_tracker.account.access.mobile_or_oauth_verified?
      end
    end
  end
end
