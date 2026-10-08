# frozen_string_literal: true

module PasswordResetRateLimiting
  extend ActiveSupport::Concern

  RESET_COOLDOWN = 30
  RESET_WINDOW = 1.hour
  RESET_MAX_WITHIN_WINDOW = 3

  included do
    before_action :check_password_reset_rate_limit, only: :create
  end

  private

  def check_password_reset_rate_limit
    email = params.dig(:password, :email).to_s.downcase.strip
    return if email.blank?

    check_session_rate_limit(email) && check_account_rate_limit(email)
  end

  def check_session_rate_limit(email)
    attempts = load_recent_session_attempts(email)
    if at_session_cap?(attempts)
      render_cap_error and return false
    elsif in_session_cooldown?(attempts)
      render_cooldown_error(session_seconds_remaining(email)) and return false
    else
      record_session_attempt(email, attempts)
      true
    end
  end

  def check_account_rate_limit(email)
    user = find_user_for_rate_limit(email)
    return true unless user

    enforce_account_rate_limit(user)
  end

  def enforce_account_rate_limit(user)
    return true unless user.password_reset_requested_at&.>=(RESET_WINDOW.ago)

    elapsed = Time.current - user.password_reset_requested_at
    if elapsed < RESET_COOLDOWN
      render_cooldown_error(RESET_COOLDOWN - elapsed) and return false
    elsif user.password_reset_count >= RESET_MAX_WITHIN_WINDOW
      render_cap_error and return false
    end

    true
  end

  def record_password_reset_request(account)
    account.with_lock do
      account.reload
      now = Time.current
      last = account.password_reset_requested_at

      next false if cooldown_blocked?(last, now)
      next false if cap_blocked?(last, now, account.password_reset_count)

      update_account_rate_limit(account, last, now)
      true
    end
  end

  def cooldown_blocked?(last, now)
    last && (now - last) < RESET_COOLDOWN
  end

  def cap_blocked?(last, now, count)
    window_start = now - RESET_WINDOW
    in_window = last && last >= window_start
    in_window && count >= RESET_MAX_WITHIN_WINDOW
  end

  def update_account_rate_limit(account, last, now)
    window_start = now - RESET_WINDOW
    in_window = last && last >= window_start
    new_count = in_window ? account.password_reset_count + 1 : 1
    account.update_columns(
      password_reset_count: new_count,
      password_reset_requested_at: now,
      updated_at: now
    )
  end

  def find_user_for_rate_limit(email)
    Clearance.configuration.user_model.find_by(email: email)
  end

  # Session-based tracking

  def session_key(email)
    "password_reset_attempts_#{email}"
  end

  def load_recent_session_attempts(email)
    attempts = session[session_key(email)] || {}
    now = Time.current.to_i
    attempts.select { |ts, _| ts.to_i >= (now - RESET_WINDOW.to_i) }
  end

  def record_session_attempt(email, attempts)
    session[session_key(email)] = attempts.merge(Time.current.to_i => true)
  end

  def at_session_cap?(attempts)
    attempts.size >= RESET_MAX_WITHIN_WINDOW
  end

  def in_session_cooldown?(attempts)
    return false if attempts.empty?

    last_attempt = attempts.keys.map(&:to_i).max
    (Time.current.to_i - last_attempt) < RESET_COOLDOWN
  end

  def session_seconds_remaining(email)
    attempts = session[session_key(email)] || {}
    return 0 if attempts.empty?

    last_attempt = attempts.keys.map(&:to_i).max
    [RESET_COOLDOWN - (Time.current.to_i - last_attempt), 0].max
  end

  def render_cooldown_error(seconds_left)
    flash.now[:error] = t('passwords.create.rate_limit_wait', seconds: seconds_left)
    render 'alter_passwords/new', status: :too_many_requests
  end

  def render_cap_error
    flash.now[:error] = t('passwords.create.rate_limit_exceeded')
    render 'alter_passwords/new', status: :too_many_requests
  end
end
