# frozen_string_literal: true

class PasswordResetRateLimiter
  RESET_COOLDOWN = 30
  RESET_WINDOW = 10.minutes
  RESET_MAX_WITHIN_WINDOW = 3

  def initialize(session, email)
    @session = session
    @email = email
  end

  def check_and_record
    attempts = load_recent_attempts
    return :cap_exceeded if at_cap?(attempts)
    return :cooldown if in_cooldown?(attempts)

    @session[session_key] = attempts.merge(Time.current.to_i => true)
    :allowed
  end

  def seconds_remaining
    attempts = @session[session_key] || {}
    return 0 if attempts.empty?

    now = Time.current.to_i
    last_attempt = attempts.keys.map(&:to_i).max
    elapsed = now - last_attempt
    remaining = RESET_COOLDOWN - elapsed
    [remaining, 0].max
  end

  private

  def session_key
    "password_reset_attempts_#{@email}"
  end

  def load_recent_attempts
    attempts = @session[session_key] || {}
    now = Time.current.to_i
    attempts.select { |ts| ts.to_i > (now - RESET_WINDOW.to_i) }
  end

  def at_cap?(attempts)
    attempts.any? && attempts.size >= RESET_MAX_WITHIN_WINDOW
  end

  def in_cooldown?(attempts)
    return false unless attempts.any?

    now = Time.current.to_i
    last_attempt = attempts.keys.map(&:to_i).max
    (now - last_attempt) < RESET_COOLDOWN
  end
end
