# frozen_string_literal: true

module JwtLoginLockout
  JWT_MAX_ATTEMPTS = 5
  JWT_WINDOW_MINUTES = 30

  def jwt_locked?(account)
    return false unless account&.jwt_locked_until

    account.jwt_locked_until > Time.current
  end

  def handle_jwt_auth_failure(account)
    return unless account

    window_expired?(account) ? reset_window(account) : increment_attempts(account)
    lock_account_for_jwt(account) if account.jwt_failed_attempts >= JWT_MAX_ATTEMPTS
  end

  def handle_jwt_auth_success(account)
    return unless account

    account.update_columns(
      jwt_failed_attempts: 0,
      jwt_failed_attempts_window_start: nil,
      jwt_locked_until: nil
    )
  end

  private

  def window_expired?(account)
    window_start = account.jwt_failed_attempts_window_start
    window_start.nil? || Time.current - window_start >= JWT_WINDOW_MINUTES.minutes
  end

  def reset_window(account)
    account.update_columns(
      jwt_failed_attempts: 1,
      jwt_failed_attempts_window_start: Time.current
    )
  end

  def increment_attempts(account)
    account.increment!(:jwt_failed_attempts)
  end

  def lock_account_for_jwt(account)
    return if account_already_locked?(account)

    account.with_lock do
      account.reload
      perform_lockout(account) unless account_already_locked?(account)
    end
  end

  def account_already_locked?(account)
    account.jwt_locked_until.present? && account.jwt_locked_until > Time.current
  end

  def perform_lockout(account)
    locked_until = Time.current + JWT_WINDOW_MINUTES.minutes
    account.update_column(:jwt_locked_until, locked_until)
    send_lockout_notification(account)
  end

  def send_lockout_notification(account)
    AccountMailer.notify_jwt_temporary_lockout(account).deliver_now
    Airbrake.notify("JWT brute force lockout triggered for account: #{account.login}")
  rescue StandardError => e
    Rails.logger.warn("JWT lockout notification failed for account #{account.id}: #{e.class}: #{e.message}")
  end
end
