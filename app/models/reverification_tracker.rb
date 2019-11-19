# frozen_string_literal: true

class ReverificationTracker < ActiveRecord::Base
  MAX_ATTEMPTS = 3
  NOTIFICATION1_DUE_DAYS = 21
  NOTIFICATION2_DUE_DAYS = 140
  NOTIFICATION3_DUE_DAYS = 28
  NOTIFICATION4_DUE_DAYS = 14
  belongs_to :account
  enum status: { pending: 0, delivered: 1, soft_bounced: 2, complained: 3 }
  enum phase: { initial: 0, marked_for_disable: 1, disabled: 2, final_warning: 3 }

  scope :soft_bounced_until_yesterday, lambda {
    soft_bounced.includes(:account).where('DATE(sent_at) < DATE(NOW())')
                .order(sent_at: :asc)
  }
  scope :max_attempts_not_reached, -> { where("attempts < #{MAX_ATTEMPTS}") }

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
      initial.includes(:account).where('(status = 1 OR (status = 2 AND attempts = 3))')
             .where("(NOW()::DATE - sent_at::DATE) >= #{NOTIFICATION1_DUE_DAYS}")
             .limit(limit)
    end

    def expired_second_phase_notifications(limit = nil)
      marked_for_disable.includes(:account).where('(status = 1 OR (status = 2 AND attempts = 3))')
                        .where("(NOW()::DATE - sent_at::DATE) >= #{NOTIFICATION2_DUE_DAYS}")
                        .limit(limit)
    end

    def expired_third_phase_notifications(limit = nil)
      disabled.includes(:account).where('(status = 1 OR (status = 2 AND attempts = 3))')
              .where("(NOW()::DATE - sent_at::DATE) >= #{NOTIFICATION3_DUE_DAYS}")
              .limit(limit)
    end

    def expired_final_phase_notifications(limit = nil)
      final_warning.includes(:account).where('(status = 1 OR (status = 2 AND attempts = 3))')
                   .where("(NOW()::DATE - sent_at::DATE) >= #{NOTIFICATION4_DUE_DAYS}")
                   .limit(limit)
    end

    def destroy_account(email_address)
      account = Account.find_by(email: email_address)
      return unless account

      account.destroy
    end

    def cleanup
      remove_reverification_trackers_for_verified_accounts
      delete_expired_accounts
      disable_accounts
      remove_orphans
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
        rev_tracker.account.update!(level: -10) unless rev_tracker.account.access.disabled?
      end
    end

    def remove_reverification_trackers_for_verified_accounts
      includes(:account).find_each do |rev_tracker|
        next unless rev_tracker.account

        rev_tracker.account.update!(level: 0) if rev_tracker.account.level == -10
        rev_tracker.destroy if rev_tracker.account.access.mobile_or_oauth_verified?
      end
    end

    def remove_orphans
      find_each do |rev_tracker|
        rev_tracker.destroy unless rev_tracker.account
      end
    end

    def update_tracker(rev_tracker, phase, response)
      if phase == rev_tracker.phase_value
        rev_tracker.increment! :attempts
      else
        rev_tracker.update attempts: 1
      end
      rev_tracker.update(message_id: response[:message_id], status: 0, phase: phase, sent_at: Time.now.utc)
    end
  end
end
