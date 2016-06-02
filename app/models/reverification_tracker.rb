class ReverificationTracker < ActiveRecord::Base
  belongs_to :account
  enum status: [:pending, :delivered, :soft_bounced, :complained]
  enum phase: [:initial, :marked_for_disable, :disabled, :final_warning]

  scope :soft_bounced_until_yesterday, -> { soft_bounced.where('DATE(sent_at) < DATE(NOW())').order(sent_at: :asc) }
  scope :max_attempts_not_reached, -> { where("attempts < #{Reverification::Mailer::MAX_ATTEMPTS}") }

  def template_hash
    templ = case
            when initial? then :first_reverification_notice
            when marked_for_disable? then :marked_for_disable_notice
            when disabled? then :account_is_disabled_notice
            when final_warning? then :final_warning_notice
            end
    Reverification::Template.send(templ, account.email)
  end

  def phase_value
    self.class.phases[phase]
  end

  class << self
    def expired_initial_phase_notifications(limit = nil)
      initial.where('(status = 1 OR (status = 2 AND attempts = 3))')
        .where("(NOW()::DATE - sent_at::DATE) >= #{Reverification::Mailer::NOTIFICATION1_DUE_DAYS}").limit(limit)
    end

    def expired_second_phase_notifications(limit = nil)
      marked_for_disable.where('(status = 1 OR (status = 2 AND attempts = 3))')
        .where("(NOW()::DATE - sent_at::DATE) >= #{Reverification::Mailer::NOTIFICATION2_DUE_DAYS}").limit(limit)
    end

    def expired_third_phase_notifications(limit = nil)
      disabled.where('(status = 1 OR (status = 2 AND attempts = 3))')
        .where("(NOW()::DATE - sent_at::DATE) >= #{Reverification::Mailer::NOTIFICATION3_DUE_DAYS}").limit(limit)
    end

    def expired_final_phase_notifications(limit = nil)
      final_warning.where('(status = 1 OR (status = 2 AND attempts = 3))')
        .where("(NOW()::DATE - sent_at::DATE) >= #{Reverification::Mailer::NOTIFICATION4_DUE_DAYS}").limit(limit)
    end

    def destroy_account(email_address)
      account = Account.find_by_email(email_address)
      return unless account
      account.access.spam!
      account.destroy
    end

    def delete_expired_accounts
      expired_final_phase_notifications.each do |rev_tracker|
        unless rev_tracker.account
          rev_tracker.destroy
          next
        end
        rev_tracker.account.access.spam!
        rev_tracker.account.destroy
      end
    end

    def disable_accounts
      ReverificationTracker.disabled.find_each do |rev_tracker|
        rev_tracker.account.update_attributes!(level: -10) unless rev_tracker.account.access.disabled?
      end
    end

    def remove_reverification_trackers_for_verified_accounts
      includes(:account).find_each do |rev_tracker|
        next unless rev_tracker.account
        rev_tracker.destroy if rev_tracker.account.access.mobile_or_oauth_verified?
      end
    end

    def remove_orphans
      find_each do |rev_tracker|
        rev_tracker.destroy unless rev_tracker.account
      end
    end
  end
end
