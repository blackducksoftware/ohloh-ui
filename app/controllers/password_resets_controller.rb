# frozen_string_literal: true

class PasswordResetsController < Clearance::PasswordsController
  before_action :check_password_reset_rate_limit, only: :create

  RESET_COOLDOWN = 30
  RESET_WINDOW = 10.minutes
  RESET_MAX_WITHIN_WINDOW = 3

  private

  def deliver_email(account)
    return unless record_password_reset_request(account)

    ::ClearanceMailer.change_password(account).deliver_now
  end

  def find_user_by_id_and_confirmation_token
    token = params[:token] || session[:password_reset_token]

    Clearance.configuration.user_model
             .find_by(login: params[:account_id], confirmation_token: token.to_s)
  end

  def flash_failure_when_forbidden
    flash.now[:error] = t('passwords.token_expired_error')
  end

  def check_password_reset_rate_limit
    email = params.dig(:password, :email).to_s.downcase.strip
    return if email.blank?

    limiter = PasswordResetRateLimiter.new(session, email)
    handle_rate_limit_result(limiter, email)
  end

  def handle_rate_limit_result(limiter, email)
    case limiter.check_and_record
    when :cap_exceeded
      render_cap_error
    when :cooldown
      render_cooldown_error(limiter.seconds_remaining)
    when :allowed
      check_account_rate_limit(email)
    end
  end

  def check_account_rate_limit(email)
    user = find_user_for_rate_limit(email)
    enforce_account_rate_limit(user) if user
  end

  def enforce_account_rate_limit(user)
    return unless user.password_reset_requested_at&.> RESET_WINDOW.ago

    enforce_cooldown_or_cap(user)
  end

  def enforce_cooldown_or_cap(user)
    elapsed = Time.current - user.password_reset_requested_at
    if elapsed < RESET_COOLDOWN
      render_cooldown_error(elapsed)
    elsif user.password_reset_count >= RESET_MAX_WITHIN_WINDOW
      render_cap_error
    end
  end

  def render_cooldown_error(seconds_left)
    flash.now[:error] = t('passwords.create.rate_limit_wait', seconds: seconds_left)
    render 'alter_passwords/new', status: :too_many_requests
  end

  def render_cap_error
    flash.now[:error] = t('passwords.create.rate_limit_exceeded')
    render 'alter_passwords/new', status: :too_many_requests
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
    in_window = last && last > window_start
    in_window && count >= RESET_MAX_WITHIN_WINDOW
  end

  def update_account_rate_limit(account, last, now)
    window_start = now - RESET_WINDOW
    in_window = last && last > window_start
    new_count = in_window ? account.password_reset_count + 1 : 1
    account.update_columns(
      password_reset_count: new_count,
      password_reset_requested_at: now,
      updated_at: now
    )
  end

  def find_user_for_rate_limit(email = nil)
    email ||= params.dig(:password, :email).to_s.downcase.strip
    return nil if email.blank?

    Clearance.configuration.user_model.find_by(email: email)
  end
end
