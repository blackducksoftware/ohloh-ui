class ReverificationTracker < ActiveRecord::Base
  belongs_to :account
  enum status: [:pending, :delivered, :soft_bounced, :complained]
  enum phase: [:initial, :marked_for_spam, :spam, :final_warning]

  scope :soft_bounced_until_yesterday, -> { soft_bounced.where('DATE(sent_at) < DATE(NOW())').order(sent_at: :asc) }
  scope :max_attempts_not_reached, -> { where("attempts < #{Reverification::Mailer::MAX_ATTEMPTS}") }

  class << self
    def expired_initial_phase_notifications(limit = nil)
      initial.where("(status = 1 OR (status = 2 AND attempts = 3))").
        where("(NOW()::DATE - sent_at::DATE) >= #{Reverification::Mailer::NOTIFICATION1_DUE_DAYS}").limit(limit)
    end

    def expired_second_phase_notifications(limit = nil)
      marked_for_spam.where("(status = 1 OR (status = 2 AND attempts = 3))").
        where("(NOW()::DATE - sent_at::DATE) >= #{Reverification::Mailer::NOTIFICATION2_DUE_DAYS}").limit(limit)
    end

    def expired_third_phase_notifications(limit = nil)
      spam.where("(status = 1 OR (status = 2 AND attempts = 3))").
        where("(NOW()::DATE - sent_at::DATE) >= #{Reverification::Mailer::NOTIFICATION3_DUE_DAYS}").limit(limit)
    end

    def expired_final_phase_notifications(limit = nil)
      final_warning.where("(status = 1 OR (status = 2 AND attempts = 3))").
        where("(NOW()::DATE - sent_at::DATE) >= #{Reverification::Mailer::NOTIFICATION4_DUE_DAYS}").limit(limit)
    end

    def destroy_account(email_address)
      account = Account.find_by_email(email_address)
      account.destroy if account
    end

    def delete_expired_accounts
      expired_final_phase_notifications.each do |rev_tracker|
        rev_tracker.account.destroy
      end
    end

    def remove_reverification_trackers_for_verifed_accounts
      find_each do |rev_tracker|
        rev_tracker.destroy if rev_tracker.account.access.mobile_or_oauth_verified?
      end
    end
  end
end
